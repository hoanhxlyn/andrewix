import { describe, expect, test } from "bun:test";
import { parseFavorites, toggled, wallId } from "@/helper/favorites";

describe("wallId", () => {
  test("joins the source and the path", () => {
    expect(wallId({ source: "gruvbox", path: "a/b.png", url: "" })).toBe(
      "gruvbox/a/b.png",
    );
  });
});

describe("parseFavorites", () => {
  test("reads a stored list of ids", () => {
    expect([...parseFavorites(["local/a.png", "gruvbox/b.png"])]).toEqual([
      "local/a.png",
      "gruvbox/b.png",
    ]);
  });

  test("reads nothing stored, or anything but a list, as no favorites", () => {
    expect(parseFavorites(undefined).size).toBe(0);
    expect(parseFavorites("local/a.png").size).toBe(0);
    expect(parseFavorites({ 0: "local/a.png" }).size).toBe(0);
  });

  test("drops entries that are not ids", () => {
    expect([...parseFavorites(["local/a.png", 1, null])]).toEqual([
      "local/a.png",
    ]);
  });
});

describe("toggled", () => {
  test("adds a missing id and removes a present one", () => {
    const added = toggled(new Set(["a"]), "b");
    expect([...added]).toEqual(["a", "b"]);
    expect([...toggled(added, "a")]).toEqual(["b"]);
  });

  test("leaves the given set untouched", () => {
    const favorites = new Set(["a"]);
    toggled(favorites, "a");
    expect([...favorites]).toEqual(["a"]);
  });
});
