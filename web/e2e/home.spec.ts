import { expect, type Page, test } from "@playwright/test";

const desktop = { width: 1440, height: 900 };
const mobile = { width: 390, height: 844 };

/** Opens the config browser on a fixed viewport, at the given query string. */
async function openHome(page: Page, search = ""): Promise<void> {
  await page.setViewportSize(desktop);
  await page.goto(`/${search}`);
  await expect(
    page.getByRole("treegrid", { name: "Config files" }),
  ).toBeVisible();
}

const tree = (page: Page) =>
  page.getByRole("treegrid", { name: "Config files" });
const row = (page: Page, name: string) =>
  tree(page).getByRole("row", { name, exact: true });
const tabs = (page: Page) =>
  page.getByRole("tablist", { name: "Open files" }).getByRole("tab");
const shownFile = (page: Page) => new URL(page.url()).searchParams.get("f");
const source = (page: Page) => page.getByRole("tabpanel").locator("pre");

test("a file in the URL opens as a tab, with its folders open in the tree", async ({
  page,
}) => {
  await openHome(page, "?f=modules/devices/workstation.nix");

  await expect(tabs(page)).toHaveText(["workstation.nix"]);
  await expect(tabs(page).first()).toHaveAttribute("aria-selected", "true");
  await expect(source(page)).toContainText("<core.hardware>");
  await expect(row(page, "workstation.nix")).toHaveAttribute(
    "aria-selected",
    "true",
  );
});

test("picking files in the tree opens tabs and lives in the URL", async ({
  page,
}) => {
  await openHome(page);
  await expect(page.getByText("Pick a file in the tree.")).toBeVisible();

  await tree(page).getByRole("button", { name: "Expand modules" }).click();
  await row(page, "hosts.nix").click();
  await expect.poll(() => shownFile(page)).toBe("modules/hosts.nix");
  await row(page, "schema.nix").click();
  await expect.poll(() => shownFile(page)).toBe("modules/schema.nix");
  await expect(tabs(page)).toHaveText(["hosts.nix", "schema.nix"]);

  // Each folder reads its own open state; closing one drops its rows.
  await tree(page).getByRole("button", { name: "Collapse modules" }).click();
  await expect(row(page, "hosts.nix")).toHaveCount(0);
});

test("closing the shown tab shows its right neighbour, else the new last one", async ({
  page,
}) => {
  await openHome(page);
  await tree(page).getByRole("button", { name: "Expand modules" }).click();
  for (const name of ["hosts.nix", "schema.nix", "iso.nix"]) {
    await row(page, name).click();
  }
  await tabs(page).nth(1).click();
  await expect.poll(() => shownFile(page)).toBe("modules/schema.nix");

  await page.getByRole("button", { name: "Close schema.nix" }).click();
  await expect.poll(() => shownFile(page)).toBe("modules/iso.nix");
  await expect(tabs(page)).toHaveText(["hosts.nix", "iso.nix"]);

  await page.getByRole("button", { name: "Close iso.nix" }).click();
  await expect.poll(() => shownFile(page)).toBe("modules/hosts.nix");

  // Closing a tab that is not shown keeps the shown file.
  await row(page, "schema.nix").click();
  await page.getByRole("button", { name: "Close hosts.nix" }).click();
  await expect.poll(() => shownFile(page)).toBe("modules/schema.nix");
  await expect(tabs(page)).toHaveText(["schema.nix"]);
});

test("following an aspect link opens its file, and Back returns", async ({
  page,
}) => {
  await openHome(page, "?f=modules/devices/workstation.nix");

  await source(page).getByRole("link", { name: "<core.hardware>" }).click();
  await expect
    .poll(() => shownFile(page))
    .toBe("modules/core/hardware/default.nix");
  await expect(tabs(page)).toHaveText(["workstation.nix", "default.nix"]);

  await page.goBack();
  await expect
    .poll(() => shownFile(page))
    .toBe("modules/devices/workstation.nix");
});

test("the search filters the tree and lives in the URL", async ({ page }) => {
  await openHome(page);
  await page.getByRole("searchbox").fill("hosts.nix");
  await expect
    .poll(() => new URL(page.url()).searchParams.get("q"))
    .toBe("hosts.nix");
  await expect(row(page, "hosts.nix")).toBeVisible();
  await expect(row(page, "schema.nix")).toHaveCount(0);

  // A link with the search opens on the same filtered tree.
  await openHome(page, "?q=schema.nix");
  await expect(page.getByRole("searchbox")).toHaveValue("schema.nix");
  await expect(row(page, "schema.nix")).toBeVisible();
  await expect(row(page, "hosts.nix")).toHaveCount(0);
});

test("a path outside the config has no tab", async ({ page }) => {
  await openHome(page, "?f=modules/missing.nix");
  await expect(page.getByText("Not a file of the config.")).toBeVisible();
  await expect(tabs(page)).toHaveCount(0);
});

test("tabs, wrapping and the hidden tree are remembered across a reload", async ({
  page,
}) => {
  await openHome(page, "?f=modules/hosts.nix");
  await row(page, "schema.nix").click();
  await expect(source(page)).toBeVisible();

  const wrapped = () =>
    source(page).evaluate(
      (el) => getComputedStyle(el.firstElementChild as Element).display,
    );
  await expect.poll(wrapped).toBe("block");
  await page.getByText("wrap", { exact: true }).click();
  await expect.poll(wrapped).toBe("flex");
  await page.getByRole("button", { name: "Hide the tree" }).click();

  await page.goto("/?f=modules/schema.nix");
  await expect(tabs(page)).toHaveText(["hosts.nix", "schema.nix"]);
  await expect(page.getByRole("checkbox", { name: "wrap" })).toBeChecked();
  await expect.poll(wrapped).toBe("flex");
  await expect(
    page.getByRole("button", { name: "Show the tree" }),
  ).toBeVisible();
});

test("stored values in the wrong shape fall back to the defaults", async ({
  page,
}) => {
  // Seeded from a first visit, so the next load reads them at start-up like stored settings.
  await page.goto("/");
  await page.evaluate(
    (settings) =>
      new Promise<void>((resolve, reject) => {
        const open = indexedDB.open("andrewix-settings");
        open.onupgradeneeded = () => open.result.createObjectStore("settings");
        open.onerror = () => reject(open.error);
        open.onsuccess = () => {
          const write = open.result.transaction("settings", "readwrite");
          const store = write.objectStore("settings");
          for (const [key, value] of Object.entries(settings)) {
            store.put(value, key);
          }
          write.oncomplete = () => resolve();
          write.onerror = () => reject(write.error);
        };
      }),
    {
      "open-files": [
        "modules/missing.nix",
        "modules/hosts.nix",
        "modules/hosts.nix",
      ],
      "wrap-lines": "yes",
      "markdown-preview": null,
      "sidebar-width": 9999,
      "sidebar-shown": 1,
    },
  );
  await openHome(page, "?f=modules/README.md");

  // Missing and repeated paths are dropped; the file of the URL joins the stored tab.
  await expect(tabs(page)).toHaveText(["hosts.nix", "README.md"]);
  await expect(page.getByRole("checkbox", { name: "wrap" })).not.toBeChecked();
  await expect(page.getByRole("checkbox", { name: "preview" })).toBeChecked();
  await expect(
    page.getByRole("separator", { name: "Resize the tree" }),
  ).toHaveAttribute("aria-valuenow", "300");
  await expect(
    page.getByRole("button", { name: "Hide the tree" }),
  ).toBeVisible();
});

test.describe("on a touch screen", () => {
  test.use({ hasTouch: true, isMobile: true, viewport: mobile });

  test("a tap toggles the preview and wrap checkboxes, each a finger-sized target", async ({
    page,
  }) => {
    await page.goto("/?f=modules/README.md");
    for (const [name, initial] of [
      ["preview", true],
      ["wrap", false],
    ] as const) {
      const checkbox = page.getByRole("checkbox", { name });
      const label = page.locator("label").filter({ has: checkbox });
      await expect(checkbox).toBeChecked({ checked: initial });
      const box = await label.boundingBox();
      expect(box?.height).toBeGreaterThanOrEqual(48);
      await label.tap();
      await expect(checkbox).toBeChecked({ checked: !initial });
      await label.tap();
      await expect(checkbox).toBeChecked({ checked: initial });
    }
  });
});
