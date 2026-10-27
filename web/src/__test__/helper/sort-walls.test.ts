import { describe, expect, test } from "bun:test";
import type { Wall } from "@/data/walls";
import { wallId } from "@/helper/favorites";
import { byName, nameOf, sorted, withoutExtension } from "@/helper/sort-walls";

const wall = (path: string, source = "local"): Wall => ({
  source,
  path,
  url: "",
});
const names = (walls: Wall[]) => walls.map((w) => nameOf(w.path));
const sources = (walls: Wall[]) => walls.map((w) => w.source);

const walls = [wall("b/wall10.png"), wall("a/wall2.png"), wall("Forest")];
const mixed = [
  wall("a.png", "tokyonight"),
  wall("b.png", "gruvbox"),
  wall("c.png", "local"),
];

describe("withoutExtension", () => {
  test("drops only the extension of the name", () => {
    expect(withoutExtension("nature/forest.png")).toBe("nature/forest");
    expect(withoutExtension("a.1/wall.2.jpg")).toBe("a.1/wall.2");
    expect(withoutExtension("forest")).toBe("forest");
  });
});

describe("nameOf", () => {
  test("is the last segment of the path, without its extension", () => {
    expect(nameOf("nature/forest.png")).toBe("forest");
    expect(nameOf("forest.png")).toBe("forest");
    expect(nameOf("forest")).toBe("forest");
  });
});

describe("byName", () => {
  test("compares numbers in names by value", () => {
    expect(byName(wall("wall2"), wall("wall10"))).toBeLessThan(0);
  });

  test("ignores the folders of the path", () => {
    expect(byName(wall("z/a.png"), wall("a/b.png"))).toBeLessThan(0);
  });
});

describe("sorted", () => {
  const none = new Set<string>();

  test("keeps the source order without a sort", () => {
    expect(sorted(walls, null, none)).toBe(walls);
  });

  test("orders names A to Z and Z to A", () => {
    expect(
      names(sorted(walls, { column: "name", order: "asc" }, none)),
    ).toEqual(["Forest", "wall2", "wall10"]);
    expect(
      names(sorted(walls, { column: "name", order: "desc" }, none)),
    ).toEqual(["wall10", "wall2", "Forest"]);
  });

  test("orders sources A to Z and Z to A, names within a source", () => {
    expect(
      sources(sorted(mixed, { column: "source", order: "asc" }, none)),
    ).toEqual(["gruvbox", "local", "tokyonight"]);
    expect(
      sources(sorted(mixed, { column: "source", order: "desc" }, none)),
    ).toEqual(["tokyonight", "local", "gruvbox"]);
  });

  test("puts the favorites first or last, names within each side", () => {
    const favorites = new Set([wallId(wall("b.png", "gruvbox"))]);
    expect(
      sources(sorted(mixed, { column: "favorite", order: "asc" }, favorites)),
    ).toEqual(["gruvbox", "tokyonight", "local"]);
    expect(
      sources(sorted(mixed, { column: "favorite", order: "desc" }, favorites)),
    ).toEqual(["local", "tokyonight", "gruvbox"]);
  });

  test("leaves the given list untouched", () => {
    const before = [...walls];
    sorted(walls, { column: "name", order: "desc" }, none);
    expect(walls).toEqual(before);
  });
});
