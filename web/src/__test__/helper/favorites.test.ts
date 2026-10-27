import { describe, expect, test } from "bun:test";
import {
  favoriteFileName,
  parseFavorites,
  readFavoriteFile,
  serializeFavorites,
  wallId,
  withFavorite,
} from "@/helper/favorites";

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

describe("serializeFavorites and readFavoriteFile", () => {
  test("a written file reads back as the favorites it holds", () => {
    const favorites = new Set(["local/a.png", "gruvbox/b.png"]);
    expect([
      ...(readFavoriteFile(serializeFavorites(favorites)) ?? []),
    ]).toEqual(["local/a.png", "gruvbox/b.png"]);
  });

  test("writes an empty list when nothing is starred", () => {
    expect(serializeFavorites(new Set())).toBe("[]\n");
    expect(readFavoriteFile("[]\n")?.size).toBe(0);
  });

  test("reads anything that is not a list as no file", () => {
    expect(readFavoriteFile("")).toBeNull();
    expect(readFavoriteFile("{")).toBeNull();
    expect(readFavoriteFile('{"favorites":[]}')).toBeNull();
    expect(readFavoriteFile("null")).toBeNull();
  });
});

describe("favoriteFileName", () => {
  test("names the file after the words of the form", () => {
    expect(favoriteFileName("My Favorite Themes")).toBe(
      "my-favorite-themes.json",
    );
    expect(favoriteFileName("  Wallpapers 2026  ")).toBe(
      "wallpapers-2026.json",
    );
  });

  test("drops accents and punctuation, which a file name cannot keep", () => {
    expect(favoriteFileName("Grüvbox / Tokyo Night!")).toBe(
      "gruvbox-tokyo-night.json",
    );
  });

  test("falls back to a plain name when nothing is left", () => {
    expect(favoriteFileName("")).toBe("favorites.json");
    expect(favoriteFileName("⭐")).toBe("favorites.json");
  });
});

describe("withFavorite", () => {
  test("adds or removes the id as asked, whatever the set holds", () => {
    const favorites = new Set(["a"]);
    expect([...withFavorite(favorites, "b", true)]).toEqual(["a", "b"]);
    expect([...withFavorite(favorites, "a", true)]).toEqual(["a"]);
    expect([...withFavorite(favorites, "a", false)]).toEqual([]);
    expect([...withFavorite(favorites, "b", false)]).toEqual(["a"]);
  });

  test("leaves the given set untouched", () => {
    const favorites = new Set(["a"]);
    withFavorite(favorites, "a", false);
    expect([...favorites]).toEqual(["a"]);
  });
});
