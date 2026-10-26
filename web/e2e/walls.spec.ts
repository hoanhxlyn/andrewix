import { expect, type Page, test } from "@playwright/test";

/** A 1×1 PNG, for the wallpaper pictures the page would otherwise fetch from GitHub. */
const PNG = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
  "base64",
);

const desktop = { width: 1440, height: 900 };
const tablet = { width: 800, height: 1000 };
const mobile = { width: 390, height: 844 };

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

const cards = (page: Page) => page.getByTestId("wall-grid").getByRole("link");

/** Box of the modal around the dialog, which carries its size, corners and animation. */
const modalBox = (page: Page) => page.getByRole("dialog").locator("..");

/** Scrim over the page behind the modal box. */
const scrim = (page: Page) => modalBox(page).locator("..");

test("grid shows one column on mobile, three on tablet and six on desktop", async ({
  page,
}) => {
  const columns = () =>
    page
      .getByTestId("wall-grid")
      .evaluate(
        (el) => getComputedStyle(el).gridTemplateColumns.split(" ").length,
      );

  await openWalls(page, mobile);
  await expect.poll(columns).toBe(1);

  await page.setViewportSize(tablet);
  await expect.poll(columns).toBe(3);

  await page.setViewportSize(desktop);
  await expect.poll(columns).toBe(6);
});

test("wallpapers load lazily", async ({ page }) => {
  await openWalls(page);
  const images = page.getByTestId("wall-grid").locator("img");
  await expect(images.first()).toHaveAttribute("loading", "lazy");
  await expect(images.first()).toHaveAttribute("decoding", "async");
});

test("a card shows a skeleton until its picture arrives", async ({ page }) => {
  // Slower pictures than the suite's instant stub, so the placeholder is observable.
  await page.route("https://raw.githubusercontent.com/**", async (route) => {
    await new Promise((resolve) => setTimeout(resolve, 500));
    await route.fulfill({ status: 200, contentType: "image/png", body: PNG });
  });
  await openWalls(page);

  const first = cards(page).first();
  await expect(first.locator('[aria-hidden="true"]')).toBeVisible();
  await expect(first.locator('[aria-hidden="true"]')).toHaveCount(0, {
    timeout: 10_000,
  });
  await expect(first.locator("img")).toHaveAttribute("data-loaded", "true");
});

test("cards lift on hover and pictures fade in", async ({ page }) => {
  await openWalls(page);
  const card = cards(page).first();
  await expect
    .poll(() => card.evaluate((el) => getComputedStyle(el).transitionProperty))
    .toContain("transform");
  const image = card.locator("img");
  await expect
    .poll(() => image.evaluate((el) => getComputedStyle(el).transitionProperty))
    .toContain("opacity");
  await expect(image).toHaveAttribute("data-loaded", "true");
});

test("arrow keys move the focus across the cards", async ({ page }) => {
  await openWalls(page);
  const at = (index: number) => cards(page).nth(index);

  await at(0).focus();
  await page.keyboard.press("ArrowRight");
  await expect(at(1)).toBeFocused();

  // Six columns on desktop, so a row is six cards.
  await page.keyboard.press("ArrowDown");
  await expect(at(7)).toBeFocused();
  await page.keyboard.press("ArrowUp");
  await expect(at(1)).toBeFocused();
  await page.keyboard.press("ArrowLeft");
  await expect(at(0)).toBeFocused();

  // The ends stay put instead of wrapping around.
  await page.keyboard.press("ArrowLeft");
  await expect(at(0)).toBeFocused();
  await page.keyboard.press("Home");
  await expect(at(0)).toBeFocused();
  await page.keyboard.press("End");
  await expect(cards(page).last()).toBeFocused();
});

test("the grid leaves room for the focus ring and the hover shadow", async ({
  page,
}) => {
  await openWalls(page);
  const padding = await page.getByTestId("wall-grid").evaluate((el) => {
    const style = getComputedStyle(el);
    return [
      style.paddingTop,
      style.paddingRight,
      style.paddingBottom,
      style.paddingLeft,
    ];
  });
  expect(padding).toEqual(["8px", "8px", "8px", "8px"]);

  // The ring is drawn outside the card, so the padding is what keeps it from being clipped.
  const card = cards(page).first();
  await card.focus();
  const ring = await card.evaluate((el) => {
    const style = getComputedStyle(el);
    return `${style.outlineWidth} ${style.outlineStyle}`;
  });
  expect(ring).toBe("2px solid");
});

test("search narrows the grid and lives in the URL", async ({ page }) => {
  await openWalls(page);
  const all = await cards(page).count();
  expect(all).toBeGreaterThan(100);

  await page.getByRole("searchbox").fill("forest");
  await expect.poll(() => cards(page).count()).toBeLessThan(all);
  expect(page.url()).toContain("q=forest");

  await page.getByRole("button", { name: "Clear search" }).click();
  await expect.poll(() => cards(page).count()).toBe(all);
  expect(page.url()).not.toContain("q=");
});

test("source chips filter by source and live in the URL", async ({ page }) => {
  await openWalls(page);
  const all = await cards(page).count();

  await page.getByText("Gruvbox", { exact: true }).click();
  await expect.poll(() => cards(page).count()).toBeLessThan(all);
  expect(page.url()).toContain("s=gruvbox");
  await expect(
    page.getByTestId("wall-grid").getByText("tokyonight", { exact: true }),
  ).toHaveCount(0);

  await page.getByText("Tokyo Night", { exact: true }).click();
  await expect.poll(() => cards(page).count()).toBe(32);
  await expect(
    page.getByTestId("wall-grid").getByText("gruvbox", { exact: true }),
  ).toHaveCount(0);

  await page.getByText("All", { exact: true }).click();
  await expect.poll(() => cards(page).count()).toBe(all);
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
    cards(page)
      .locator("span[title]")
      .evaluateAll((names, dir) => {
        const text = names.map((name) => name.textContent ?? "");
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
  const first = () => cards(page).first().locator("span[title]").textContent();
  const unsorted = await first();

  await sortBy(page, "A–Z");
  await expect.poll(() => new URL(page.url()).searchParams.get("o")).toBe("az");
  await expect.poll(() => inOrder(1)).toBe(true);
  await expect(
    page.getByRole("button", { name: "Sort by name: A–Z" }),
  ).toBeVisible();

  await sortBy(page, "Z–A");
  await expect.poll(() => new URL(page.url()).searchParams.get("o")).toBe("za");
  await expect.poll(() => inOrder(-1)).toBe(true);

  // The order rides along into the dialog route and back.
  await cards(page).first().click();
  await expect(page).toHaveURL(/o=za/);
  await page.getByRole("button", { name: "Close" }).click();
  await expect(page).toHaveURL(/\/walls\?o=za$/);

  await sortBy(page, "Default");
  await expect.poll(() => new URL(page.url()).searchParams.get("o")).toBeNull();
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

  await cards(page).first().click();
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

  await cards(page).first().click();
  await page.getByRole("button", { name: "Close" }).click();

  await expect(page).toHaveURL(/\/walls\?q=forest&s=gruvbox$/);
  await expect(page.getByRole("searchbox")).toHaveValue("forest");
});

test("Escape and the backdrop close the dialog too", async ({ page }) => {
  await openWalls(page);

  await cards(page).first().click();
  await expect(page.getByRole("dialog")).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(page).toHaveURL(/\/walls$/);

  await cards(page).first().click();
  await expect(page.getByRole("dialog")).toBeVisible();
  // Well outside the centred dialog, which is 80% of the window.
  await page.mouse.click(5, 5);
  await expect(page).toHaveURL(/\/walls$/);
});

test("the dialog fills the screen on mobile", async ({ page }) => {
  await openWalls(page, mobile);
  await cards(page).first().click();

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
  await cards(page).first().click();
  await expect
    .poll(() =>
      modalBox(page).evaluate((el) => getComputedStyle(el).animationName),
    )
    .toBe("none");
});
