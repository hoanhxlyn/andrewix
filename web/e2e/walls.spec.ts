import { readFile, writeFile } from "node:fs/promises";
import { expect, type Locator, type Page, test } from "@playwright/test";
import { storedSetting } from "./settings";

/** A 1×1 PNG, for the wallpaper pictures the page would otherwise fetch from GitHub. */
const PNG = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
  "base64",
);

const desktop = { width: 1440, height: 900 };
const tablet = { width: 800, height: 1000 };
const mobile = { width: 390, height: 844 };

/** Wallpapers each batch adds to the list, as `gallery.batchSize` in `src/styles/tokens.css.ts`. */
const BATCH = 48;

test.beforeEach(async ({ page }) => {
  await page.route("https://raw.githubusercontent.com/**", (route) =>
    route.fulfill({ status: 200, contentType: "image/png", body: PNG }),
  );
});

/** Opens the gallery on a fixed viewport, so layout assertions are stable. */
async function openWalls(page: Page, viewport = desktop): Promise<void> {
  await page.setViewportSize(viewport);
  await page.goto("/walls");
  await expect(page.getByTestId("wall-grid")).toBeVisible();
}

const grid = (page: Page) => page.getByTestId("wall-grid");

/**
 * Cards the virtualizer has rendered, which are only the ones in or near the view. The row of the
 * progress circle has no index, so it is left out.
 */
const cards = (page: Page) => grid(page).locator('[role="row"][aria-rowindex]');

/** Card at this place in the grid, counted from 0 over every wallpaper shown. */
const card = (page: Page, index: number) =>
  grid(page).locator(`[role="row"][aria-rowindex="${index + 1}"]`);

/** Number of wallpapers loaded so far, rendered or not, as the grid tells assistive technology. */
const shown = async (page: Page): Promise<number> =>
  Number(await grid(page).getAttribute("aria-rowcount"));

/**
 * Scrolls a list to its end until its last batch is in, which the progress circle at its end going
 * away tells.
 */
async function loadAll(list: Locator): Promise<void> {
  await expect
    .poll(
      async () => {
        await list.evaluate((el) => el.scrollTo(0, el.scrollHeight));
        return list.getByRole("progressbar").count();
      },
      { intervals: [100], timeout: 20_000 },
    )
    .toBe(0);
}

/** Box of the modal around the dialog, which carries its size, corners and animation. */
const modalBox = (page: Page) => page.getByRole("dialog").locator("..");

/** Scrim over the page behind the modal box. */
const scrim = (page: Page) => modalBox(page).locator("..");

test("grid shows one column on mobile, three on tablet and six on desktop", async ({
  page,
}) => {
  /** Cards on the first row, and their widths. */
  const firstRow = () =>
    cards(page).evaluateAll((rows) => {
      const boxes = rows.map((row) => row.getBoundingClientRect());
      const top = Math.min(...boxes.map((box) => box.top));
      return boxes
        .filter((box) => Math.abs(box.top - top) < 1)
        .map((box) => Math.round(box.width));
    });
  const columns = async () => (await firstRow()).length;

  await openWalls(page, mobile);
  await expect.poll(columns).toBe(1);

  await page.setViewportSize(tablet);
  await expect.poll(columns).toBe(3);

  await page.setViewportSize(desktop);
  await expect.poll(columns).toBe(6);

  // A long file name is cut rather than widening its card.
  expect(new Set(await firstRow()).size).toBe(1);
});

test("the grid renders only the cards near the view", async ({ page }) => {
  await openWalls(page);
  await loadAll(grid(page));
  const total = await shown(page);
  expect(total).toBeGreaterThan(100);
  expect(await cards(page).count()).toBeLessThan(total);

  // Scrolling to the end brings the last cards in. Card heights are measured as they render, so
  // the end moves while the grid gets there.
  await expect
    .poll(async () => {
      await grid(page).evaluate((el) => el.scrollTo(0, el.scrollHeight));
      return card(page, total - 1).count();
    })
    .toBe(1);
  await expect(card(page, 0)).toHaveCount(0);
});

test("the grid loads in batches, with a progress circle at the end of each", async ({
  page,
}) => {
  await openWalls(page);
  expect(await shown(page)).toBe(BATCH);
  const loader = grid(page).getByRole("progressbar", {
    name: "Loading more wallpapers",
  });
  await expect(loader).toHaveCount(1);
  await expect(loader).not.toBeInViewport();
  // The M3 circular indicator: 48 by 48 pixels, its arc turning.
  const box = await loader.boundingBox();
  expect([box?.width, box?.height]).toEqual([48, 48]);
  await expect
    .poll(() =>
      loader
        .locator("svg")
        .evaluate((el) => getComputedStyle(el).animationName),
    )
    .not.toBe("none");

  // Reaching the end of the batch brings the next one in.
  await grid(page).evaluate((el) => el.scrollTo(0, el.scrollHeight));
  await expect.poll(() => shown(page)).toBe(2 * BATCH);

  // A new filter starts again from the first batch.
  await page.getByText("Gruvbox", { exact: true }).click();
  await expect(page).toHaveURL(/s=gruvbox/);
  await expect.poll(() => shown(page)).toBe(BATCH);
});

test("wallpapers load lazily", async ({ page }) => {
  await openWalls(page);
  const images = grid(page).locator("img");
  await expect(images.first()).toHaveAttribute("loading", "lazy");
  await expect(images.first()).toHaveAttribute("decoding", "async");
});

test("a card shows a skeleton until its picture arrives", async ({ page }) => {
  // Slower pictures than the suite's instant stub, so the placeholder is observable.
  await page.route("https://raw.githubusercontent.com/**", async (route) => {
    await new Promise((resolve) => setTimeout(resolve, 500));
    await route.fulfill({ status: 200, contentType: "image/png", body: PNG });
  });
  // The first cards are the local backgrounds, bundled with the site rather than fetched from
  // GitHub; they need the same delay, or they can load before the skeleton is ever checked.
  await page.route(/\/assets\/[^/]+\.(png|jpe?g|webp)$/, async (route) => {
    await new Promise((resolve) => setTimeout(resolve, 500));
    await route.continue();
  });
  await openWalls(page);

  const first = card(page, 0);
  // The skeleton sits beside the picture; the star's icon is hidden from assistive technology too.
  const skeleton = first
    .locator("img")
    .locator("..")
    .locator('[aria-hidden="true"]');
  await expect(skeleton).toBeVisible();
  await expect(skeleton).toHaveCount(0, {
    timeout: 10_000,
  });
  await expect(first.locator("img")).toHaveAttribute("data-loaded", "true");
});

test("cards rise on hover and pictures fade in", async ({ page }) => {
  await openWalls(page);
  const first = card(page, 0);
  await expect
    .poll(() => first.evaluate((el) => getComputedStyle(el).transitionProperty))
    .toContain("box-shadow");
  await first.hover();
  await expect
    .poll(() => first.evaluate((el) => getComputedStyle(el).boxShadow))
    .not.toBe("none");
  const image = first.locator("img");
  await expect
    .poll(() => image.evaluate((el) => getComputedStyle(el).transitionProperty))
    .toContain("opacity");
  await expect(image).toHaveAttribute("data-loaded", "true");
});

test("arrow keys move the focus across the cards, Tab reaches the star", async ({
  page,
}) => {
  await openWalls(page);
  await card(page, 0).focus();
  await page.keyboard.press("ArrowRight");
  await expect(card(page, 1)).toBeFocused();
  // The ring is drawn outside the card, in the gap the grid leaves around it.
  const ring = await card(page, 1).evaluate((el) => {
    const style = getComputedStyle(el);
    return `${style.outlineWidth} ${style.outlineStyle}`;
  });
  expect(ring).toBe("2px solid");

  // Six columns on desktop, so a row is six cards.
  await page.keyboard.press("ArrowDown");
  await expect(card(page, 7)).toBeFocused();
  await page.keyboard.press("ArrowUp");
  await expect(card(page, 1)).toBeFocused();
  await page.keyboard.press("ArrowLeft");
  await expect(card(page, 0)).toBeFocused();

  await page.keyboard.press("Tab");
  await expect(starOf(page, 0)).toBeFocused();
  await page.keyboard.press("Shift+Tab");
  await expect(card(page, 0)).toBeFocused();

  // End reaches the last card loaded, which the grid renders once it is scrolled to.
  const total = await shown(page);
  await page.keyboard.press("End");
  await expect(card(page, total - 1)).toBeFocused();
  await page.keyboard.press("Home");
  await expect(card(page, 0)).toBeFocused();
});

test("the grid leaves room for the focus ring and the hover shadow", async ({
  page,
}) => {
  await openWalls(page);
  const [outer, first] = await Promise.all([
    grid(page).boundingBox(),
    card(page, 0).boundingBox(),
  ]);
  expect((first?.x ?? 0) - (outer?.x ?? 0)).toBeGreaterThanOrEqual(8);
  expect((first?.y ?? 0) - (outer?.y ?? 0)).toBeGreaterThanOrEqual(8);
});

test("search narrows the grid and lives in the URL", async ({ page }) => {
  await openWalls(page);
  const all = await shown(page);
  expect(all).toBe(BATCH);

  await page.getByRole("searchbox").fill("forest");
  await expect.poll(() => shown(page)).toBeLessThan(all);
  expect(page.url()).toContain("q=forest");

  await page.getByRole("button", { name: "Clear search" }).click();
  await expect.poll(() => shown(page)).toBe(all);
  expect(page.url()).not.toContain("q=");
});

test("source chips filter by source and live in the URL", async ({ page }) => {
  await openWalls(page);
  const all = await shown(page);

  await page.getByText("Gruvbox", { exact: true }).click();
  await expect(page).toHaveURL(/s=gruvbox/);
  await expect(grid(page).getByText("tokyonight", { exact: true })).toHaveCount(
    0,
  );

  await page.getByText("Tokyo Night", { exact: true }).click();
  await expect.poll(() => shown(page)).toBe(32);
  await expect(grid(page).getByText("gruvbox", { exact: true })).toHaveCount(0);

  await page.getByText("All", { exact: true }).click();
  await expect.poll(() => shown(page)).toBe(all);
});

/** Picks an order in the sort menu of the toolbar. */
async function sortBy(page: Page, label: string): Promise<void> {
  await page.getByRole("button", { name: /^Sort by name/ }).click();
  await page.getByRole("menuitemradio", { name: label }).click();
}

test("the sort menu orders the grid by name and lives in the URL", async ({
  page,
}) => {
  await openWalls(page);
  /** Names of the shown cards in grid order, and whether they follow the given direction. */
  const inOrder = (direction: 1 | -1) =>
    cards(page).evaluateAll((rows, dir) => {
      const text = rows
        .sort(
          (a, b) =>
            Number(a.getAttribute("aria-rowindex")) -
            Number(b.getAttribute("aria-rowindex")),
        )
        .map((row) => row.querySelector("span[title]")?.textContent ?? "");
      return text.every(
        (name, i) =>
          i === 0 ||
          dir *
            (text[i - 1] ?? "").localeCompare(name, "en", {
              numeric: true,
            }) <=
            0,
      );
    }, direction);
  const first = () => card(page, 0).locator("span[title]").textContent();
  const unsorted = await first();

  await sortBy(page, "A–Z");
  await expect
    .poll(() => new URL(page.url()).searchParams.get("c"))
    .toBe("name");
  await expect
    .poll(() => new URL(page.url()).searchParams.get("o"))
    .toBe("asc");
  await expect.poll(() => inOrder(1)).toBe(true);
  await expect(
    page.getByRole("button", { name: "Sort by name: A–Z" }),
  ).toBeVisible();

  await sortBy(page, "Z–A");
  await expect
    .poll(() => new URL(page.url()).searchParams.get("o"))
    .toBe("desc");
  await expect.poll(() => inOrder(-1)).toBe(true);

  // The order rides along into the dialog route and back.
  await card(page, 0).click();
  await expect(page).toHaveURL(/c=name&o=desc/);
  await page.getByRole("button", { name: "Close" }).click();
  await expect(page).toHaveURL(/\/walls\?c=name&o=desc$/);

  await sortBy(page, "Default");
  await expect.poll(() => new URL(page.url()).searchParams.get("o")).toBeNull();
  await expect.poll(() => new URL(page.url()).searchParams.get("c")).toBeNull();
  await expect.poll(first).toBe(unsorted);
});

test("a wallpaper opens as a dialog route with its own URL", async ({
  page,
}) => {
  await openWalls(page);
  await page.getByRole("searchbox").fill("forest");
  await expect
    .poll(() => new URL(page.url()).searchParams.get("q"))
    .toBe("forest");
  const query = new URL(page.url()).search;

  await card(page, 0).click();
  const dialog = page.getByRole("dialog");
  await expect(dialog).toBeVisible();
  await expect(dialog.getByRole("button", { name: "Close" })).toBeVisible();
  await expect(page).toHaveURL(/\/walls\/.+/);
  // The filter rides along into the dialog route.
  expect(page.url()).toContain(query);

  // The dialog is 80% of the window, rounded and over a blurred scrim. Computed sizes ignore the
  // entrance transform, unlike a bounding box taken mid-animation.
  const size = await modalBox(page).evaluate((el) => {
    const style = getComputedStyle(el);
    return `${style.width} ${style.height} ${style.borderTopLeftRadius}`;
  });
  expect(size).toBe("1152px 720px 28px");
  await expect
    .poll(() =>
      scrim(page).evaluate((el) => {
        const style = getComputedStyle(el);
        return `${style.backdropFilter} ${style.backgroundColor}`;
      }),
    )
    .toBe("blur(8px) rgba(0, 0, 0, 0.32)");

  // Opening animates, unless the user asked for less motion.
  await expect
    .poll(() =>
      modalBox(page).evaluate((el) => getComputedStyle(el).animationName),
    )
    .not.toBe("none");
  // The picture fades in over its skeleton once it arrives.
  await expect
    .poll(() =>
      dialog
        .locator("img")
        .evaluate((el) => getComputedStyle(el).transitionProperty),
    )
    .toContain("opacity");
});

test("the close button returns to the same filtered grid", async ({ page }) => {
  await openWalls(page);
  await page.getByText("Gruvbox", { exact: true }).click();
  await page.getByRole("searchbox").fill("forest");
  // The search commits after a pause; the link only carries it once it is in the URL.
  await expect
    .poll(() => new URL(page.url()).searchParams.get("q"))
    .toBe("forest");

  await card(page, 0).click();
  await page.getByRole("button", { name: "Close" }).click();

  await expect(page).toHaveURL(/\/walls\?q=forest&s=gruvbox$/);
  await expect(page.getByRole("searchbox")).toHaveValue("forest");
});

test("Escape and the backdrop close the dialog too", async ({ page }) => {
  await openWalls(page);

  await card(page, 0).click();
  await expect(page.getByRole("dialog")).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(page).toHaveURL(/\/walls$/);

  await card(page, 0).click();
  await expect(page.getByRole("dialog")).toBeVisible();
  // Well outside the centred dialog, which is 80% of the window.
  await page.mouse.click(5, 5);
  await expect(page).toHaveURL(/\/walls$/);
});

test("the dialog fills the screen on mobile", async ({ page }) => {
  await openWalls(page, mobile);
  await card(page, 0).click();

  await expect
    .poll(() =>
      modalBox(page).evaluate((el) => {
        const style = getComputedStyle(el);
        return `${style.width} ${style.height} ${style.borderTopLeftRadius}`;
      }),
    )
    .toBe("390px 844px 0px");
});

test("reduced motion turns the dialog animation off", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await openWalls(page);
  await card(page, 0).click();
  await expect
    .poll(() =>
      modalBox(page).evaluate((el) => getComputedStyle(el).animationName),
    )
    .toBe("none");
});

/** Star of one card, the toggle in its top-right corner. */
function starOf(page: Page, index: number) {
  return card(page, index).getByRole("button", { name: "Favorite" });
}

test("a star in the corner of a card marks it as a favorite", async ({
  page,
}) => {
  await openWalls(page);
  const star = starOf(page, 0);
  await expect(star).toHaveAttribute("aria-pressed", "false");

  // The star sits in the top-right corner, over the picture.
  const [cardBox, starBox] = await Promise.all([
    card(page, 0).boundingBox(),
    star.boundingBox(),
  ]);
  const cardRight = (cardBox?.x ?? 0) + (cardBox?.width ?? 0);
  const starRight = (starBox?.x ?? 0) + (starBox?.width ?? 0);
  expect(starRight).toBeLessThan(cardRight);
  expect(starBox?.x).toBeGreaterThan(cardRight - (cardBox?.width ?? 0) / 4);
  expect(starBox?.y).toBeLessThan(
    (cardBox?.y ?? 0) + (cardBox?.height ?? 0) / 4,
  );

  // Pressing the star toggles it in place, without opening the dialog.
  await star.click();
  await expect(star).toHaveAttribute("aria-pressed", "true");
  await expect(page.getByRole("dialog")).toHaveCount(0);
  await star.click();
  await expect(star).toHaveAttribute("aria-pressed", "false");
});

test("favorites are kept in IndexedDB across reloads", async ({ page }) => {
  await openWalls(page);
  await starOf(page, 2).click();
  await expect(starOf(page, 2)).toHaveAttribute("aria-pressed", "true");

  await page.reload();
  await expect(starOf(page, 2)).toHaveAttribute("aria-pressed", "true");
  await expect(starOf(page, 0)).toHaveAttribute("aria-pressed", "false");

  const stored = await page.evaluate(
    () =>
      new Promise<unknown>((resolve, reject) => {
        const open = indexedDB.open("andrewix");
        open.onerror = () => reject(open.error);
        open.onsuccess = () => {
          const read = open.result
            .transaction("favorites")
            .objectStore("favorites")
            .get("walls");
          read.onerror = () => reject(read.error);
          read.onsuccess = () => resolve(read.result);
        };
      }),
  );
  expect(stored).toHaveLength(1);
});

test("favorites export as a file and import back", async ({ page }) => {
  await openWalls(page);
  await starOf(page, 0).click();
  await page
    .getByRole("button", { name: "Export and import favorites" })
    .click();
  const dialog = page.getByRole("dialog", { name: "Favorites" });
  await expect(
    dialog.getByRole("button", { name: "Export (1)" }),
  ).toBeEnabled();

  // Export hands the browser a JSON list of the starred ids.
  const download = page.waitForEvent("download");
  await dialog.getByRole("button", { name: "Export (1)" }).click();
  const saved = await download;
  // The file name comes from the dialog's form, not from a hard-coded one.
  expect(saved.suggestedFilename()).toBe("my-favorite-themes.json");
  const file = await saved.path();
  const ids: unknown = JSON.parse(await readFile(file, "utf8"));
  expect(ids).toHaveLength(1);
  expect(ids).toEqual([expect.stringMatching(/^\w+\/.+\.\w+$/)]);

  // The dialog remembers that a file was written, so its holder knows how old it is.
  await expect(
    dialog.getByText(/^Last exported .+, 1 favorite\.$/),
  ).toBeVisible();

  // Nothing starred: the dialog says so, and the file brings the star back.
  await dialog.getByRole("button", { name: "Close" }).click();
  await expect(dialog).toHaveCount(0);
  await starOf(page, 0).click();
  await expect(starOf(page, 0)).toHaveAttribute("aria-pressed", "false");
  await page
    .getByRole("button", { name: "Export and import favorites" })
    .click();
  await expect(
    dialog.getByRole("button", { name: "Export (0)" }),
  ).toBeDisabled();

  await dialog.locator('input[type="file"]').setInputFiles(file);
  await expect(
    dialog.getByText("Adds 1, for 1 starred in this browser."),
  ).toBeVisible();
  await dialog.getByRole("button", { name: "Import" }).click();
  await expect(page.getByText("Favorites imported")).toBeVisible();
  await expect(starOf(page, 0)).toHaveAttribute("aria-pressed", "true");
});

test("a favorites file can replace the starred ones instead of adding", async ({
  page,
}, testInfo) => {
  await openWalls(page);
  await starOf(page, 0).click();
  await starOf(page, 1).click();

  const file = testInfo.outputPath("favorites.json");
  await writeFile(file, JSON.stringify(["local/missing.png"]));

  await page
    .getByRole("button", { name: "Export and import favorites" })
    .click();
  const dialog = page.getByRole("dialog", { name: "Favorites" });
  await dialog.locator('input[type="file"]').setInputFiles(file);
  await dialog.getByRole("radio", { name: "Replace mine" }).click();
  await expect(dialog.getByText("Replaces your 2 with 1.")).toBeVisible();
  await dialog.getByRole("button", { name: "Import" }).click();

  // Both old stars are gone, and the file's id has no card to show on.
  await expect(starOf(page, 0)).toHaveAttribute("aria-pressed", "false");
  await expect(starOf(page, 1)).toHaveAttribute("aria-pressed", "false");
  await page
    .getByRole("button", { name: "Export and import favorites" })
    .click();
  await expect(
    dialog.getByRole("button", { name: "Export (1)" }),
  ).toBeEnabled();
});

test("a file that is not a favorites list is refused", async ({
  page,
}, testInfo) => {
  await openWalls(page);
  const file = testInfo.outputPath("notes.json");
  await writeFile(file, "not json");

  await page
    .getByRole("button", { name: "Export and import favorites" })
    .click();
  const dialog = page.getByRole("dialog", { name: "Favorites" });
  await dialog.locator('input[type="file"]').setInputFiles(file);
  await expect(dialog.getByText("Not a favorites file.")).toBeVisible();
  await expect(dialog.getByRole("button", { name: "Import" })).toHaveCount(0);
});

test("the dialog star and the card star are the same favorite", async ({
  page,
}) => {
  await openWalls(page);
  await card(page, 0).click();
  const dialogStar = page
    .getByRole("dialog")
    .getByRole("button", { name: "Favorite" });
  await expect(dialogStar).toHaveAttribute("aria-pressed", "false");
  await dialogStar.click();
  await expect(dialogStar).toHaveAttribute("aria-pressed", "true");

  await page.getByRole("button", { name: "Close" }).click();
  await expect(page.getByRole("dialog")).toHaveCount(0);
  await expect(starOf(page, 0)).toHaveAttribute("aria-pressed", "true");
});

test("the favorites chip filters the grid and lives in the URL", async ({
  page,
}) => {
  await openWalls(page);
  const all = await shown(page);
  const only = page
    .getByRole("grid", { name: "Favorites filter" })
    .getByRole("row", { name: "Favorites" });
  await expect(only).toHaveAttribute("aria-selected", "false");

  // Nothing starred yet: the filter says how to get favorites.
  await only.click();
  await expect(only).toHaveAttribute("aria-selected", "true");
  await expect
    .poll(() => new URL(page.url()).searchParams.get("f"))
    .toBe("true");
  await expect(page.getByText(/No favorite yet/)).toBeVisible();
  await only.click();
  await expect.poll(() => new URL(page.url()).searchParams.get("f")).toBeNull();

  const nameOf = (index: number) => card(page, index).locator("span[title]");
  const picked = [await nameOf(1).textContent(), await nameOf(4).textContent()];
  await starOf(page, 1).click();
  await starOf(page, 4).click();

  await only.click();
  await expect.poll(() => shown(page)).toBe(2);
  await expect(nameOf(0)).toHaveText(picked[0] ?? "");
  await expect(nameOf(1)).toHaveText(picked[1] ?? "");

  // The filter rides along into the dialog route and back.
  await card(page, 0).click();
  await expect(page).toHaveURL(/f=true/);
  await page.getByRole("button", { name: "Close" }).click();
  await expect(page).toHaveURL(/\/walls\?f=true$/);

  // The chip narrows whichever source is picked, rather than replacing it.
  await page.getByText("Local", { exact: true }).click();
  await expect.poll(() => shown(page)).toBe(1);
  await expect(only).toHaveAttribute("aria-selected", "true");
  await page.getByText("All", { exact: true }).click();
  await expect.poll(() => shown(page)).toBe(2);

  // Unstarring a shown card takes it out of the filtered grid.
  await starOf(page, 0).click();
  await expect.poll(() => shown(page)).toBe(1);

  await only.click();
  await expect.poll(() => shown(page)).toBe(all);
});

const table = (page: Page) => page.getByTestId("wall-table");

/** Row of the table at this place, counted from 0 over every wallpaper shown; 0 is under the header. */
const tableRow = (page: Page, index: number) =>
  table(page).locator(`[role="row"][aria-rowindex="${index + 2}"]`);

test("the layout switch shows the wallpapers as a table and keeps it", async ({
  page,
}) => {
  await openWalls(page);
  const total = await shown(page);
  const switchTo = (name: string) =>
    page
      .getByRole("radiogroup", { name: "Layout" })
      .getByRole("radio", { name });
  await expect(switchTo("Grid")).toBeChecked();

  await switchTo("Table").click();
  await expect(switchTo("Table")).toBeChecked();
  await expect(table(page)).toBeVisible();
  await expect(grid(page)).toHaveCount(0);
  await expect(
    table(page).getByRole("columnheader").allTextContents(),
  ).resolves.toEqual(["Picture", "Name", "Source", "Favorite"]);
  // The same wallpapers, under one header row.
  await expect(table(page)).toHaveAttribute("aria-rowcount", String(total + 1));

  // Kept across reloads, in IndexedDB rather than localStorage.
  await expect.poll(() => storedSetting(page, "walls-layout")).toBe("table");
  expect(await page.evaluate(() => localStorage.getItem("walls-layout"))).toBe(
    null,
  );
  await page.reload();
  await expect(table(page)).toBeVisible();

  await switchTo("Grid").click();
  await expect(grid(page)).toBeVisible();
  await expect.poll(() => storedSetting(page, "walls-layout")).toBe("grid");
});

test("the table sorts by pressing a column heading", async ({ page }) => {
  await openWalls(page);
  await page.getByRole("radio", { name: "Table" }).click();
  // The name order button belongs to the grid; the table sorts from its column headings.
  await expect(page.getByRole("button", { name: /^Sort by name/ })).toHaveCount(
    0,
  );

  const heading = (name: string) =>
    table(page).getByRole("columnheader", { name });
  const sortedBy = () => {
    const params = new URL(page.url()).searchParams;
    return `${params.get("c")}-${params.get("o")}`;
  };

  await heading("Name").click();
  await expect(heading("Name")).toHaveAttribute("aria-sort", "ascending");
  await expect.poll(sortedBy).toBe("name-asc");

  await heading("Name").click();
  await expect(heading("Name")).toHaveAttribute("aria-sort", "descending");
  await expect.poll(sortedBy).toBe("name-desc");

  // Sources run A to Z, so the first row is a catppuccin one rather than a local background.
  await heading("Source").click();
  await expect.poll(sortedBy).toBe("source-asc");
  await expect(tableRow(page, 0).getByText("catppuccin")).toBeVisible();

  // One starred row, brought to the top by the favorite column.
  await tableRow(page, 3).getByRole("button", { name: "Favorite" }).click();
  await heading("Favorite").click();
  await expect.poll(sortedBy).toBe("favorite-asc");
  await expect(
    tableRow(page, 0).getByRole("button", { name: "Favorite" }),
  ).toHaveAttribute("aria-pressed", "true");
});

test("on mobile the toolbar keeps its controls and chips on one line each", async ({
  page,
}) => {
  await openWalls(page, mobile);
  const search = await page
    .getByRole("searchbox", { name: "Search wallpapers" })
    .boundingBox();
  const layout = await page
    .getByRole("radiogroup", { name: "Layout" })
    .boundingBox();
  if (search === null || layout === null)
    throw new Error("toolbar not laid out");
  // Same row: their vertical extents overlap, so no empty line is left beside the switch.
  expect(layout.y).toBeLessThan(search.y + search.height);
  expect(search.y).toBeLessThan(layout.y + layout.height);
  expect(layout.x + layout.width).toBeLessThanOrEqual(mobile.width);
  await expect(page.getByRole("searchbox")).toHaveAttribute(
    "placeholder",
    "Search",
  );

  // The chips stay on one line: the favorites chip whole, the sources scrolling beside it.
  const favorites = await page
    .getByRole("row", { name: "Favorites" })
    .boundingBox();
  const all = await page
    .getByRole("row", { name: "All", exact: true })
    .boundingBox();
  if (favorites === null || all === null) throw new Error("chips not laid out");
  expect(all.y).toBe(favorites.y);
  const last = page.getByRole("row", { name: "Tokyo Night" });
  await last.scrollIntoViewIfNeeded();
  await expect(last).toBeInViewport();
  // Nothing pushes the page sideways.
  await expect
    .poll(() =>
      page.evaluate(
        () => document.documentElement.scrollWidth <= window.innerWidth,
      ),
    )
    .toBe(true);
});

test("the table renders only the rows near the view, with lazy thumbnails", async ({
  page,
}) => {
  await openWalls(page);
  await page.getByRole("radio", { name: "Table" }).click();
  const thumbnail = tableRow(page, 0).locator("img");
  await expect(thumbnail).toHaveAttribute("loading", "lazy");
  await expect(thumbnail).toHaveAttribute("decoding", "async");

  // The table loads in batches too, ending in the same progress circle while more remain.
  expect(await table(page).getAttribute("aria-rowcount")).toBe(
    String(BATCH + 1),
  );
  await loadAll(table(page));
  const total = Number(await table(page).getAttribute("aria-rowcount")) - 1;
  expect(total).toBeGreaterThan(100);
  expect(await table(page).getByRole("row").count()).toBeLessThan(total);
  await expect(tableRow(page, total - 1)).toHaveCount(1);
});

test("a row scrolled in shows its own picture, not the one of the row it replaces", async ({
  page,
}) => {
  await openWalls(page);
  await page.getByRole("radio", { name: "Table" }).click();
  await expect(tableRow(page, 0).locator("img")).toHaveAttribute(
    "data-loaded",
    "true",
  );

  // Hold every later picture. The virtualizer reuses the rows that scroll out for the ones that
  // scroll in, so a new row must not keep the old row's loaded picture while its own is on hold.
  await page.route("https://raw.githubusercontent.com/**", () => undefined);
  await page.route(/\/assets\/[^/]+\.(png|jpe?g|webp)$/, () => undefined);
  // Rows are 72 pixels high (`gallery.rowHeight`): this brings row 30 to the top, far below the
  // rows rendered at first.
  await table(page).evaluate((el) => el.scrollTo(0, 30 * 72));

  const thumbnail = tableRow(page, 30).locator("img");
  await expect(thumbnail).toBeVisible();
  await expect(thumbnail).not.toHaveAttribute("data-loaded");
  await expect(
    thumbnail.locator("..").locator('[aria-hidden="true"]'),
  ).toBeVisible();
});

test("a table row opens its wallpaper, and its star toggles in place", async ({
  page,
}) => {
  await openWalls(page);
  await page.getByRole("radio", { name: "Table" }).click();

  const star = tableRow(page, 0).getByRole("button", { name: "Favorite" });
  await star.click();
  await expect(star).toHaveAttribute("aria-pressed", "true");
  await expect(page.getByRole("dialog")).toHaveCount(0);

  await tableRow(page, 0).getByRole("rowheader").click();
  await expect(page.getByRole("dialog")).toBeVisible();
  await expect(
    page.getByRole("dialog").getByRole("button", { name: "Favorite" }),
  ).toHaveAttribute("aria-pressed", "true");
  await page.getByRole("button", { name: "Close" }).click();
  await expect(table(page)).toBeVisible();
});

test("a table thumbnail shows a skeleton until its picture arrives", async ({
  page,
}) => {
  // Slower pictures than the suite's instant stub, so the placeholder is observable; the local
  // backgrounds come first and are bundled with the site, so they are held back too.
  await page.route("https://raw.githubusercontent.com/**", async (route) => {
    await new Promise((resolve) => setTimeout(resolve, 500));
    await route.fulfill({ status: 200, contentType: "image/png", body: PNG });
  });
  await page.route(/\/assets\/[^/]+\.(png|jpe?g|webp)$/, async (route) => {
    await new Promise((resolve) => setTimeout(resolve, 500));
    await route.continue();
  });
  await openWalls(page);
  await page.getByRole("radio", { name: "Table" }).click();

  const thumbnail = tableRow(page, 0).locator("img");
  const skeleton = thumbnail.locator("..").locator('[aria-hidden="true"]');
  await expect(skeleton).toBeVisible();
  await expect(skeleton).toHaveCount(0, { timeout: 10_000 });
  await expect(thumbnail).toHaveAttribute("data-loaded", "true");
});
