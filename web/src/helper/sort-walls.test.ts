import { describe, expect, test } from "bun:test";
import type { Wall } from "@/data/walls";
import { byName, nameOf, sorted } from "./sort-walls";

const wall = (path: string): Wall => ({ source: "local", path, url: "" });
const names = (walls: Wall[]) => walls.map((w) => nameOf(w.path));

const walls = [wall("b/wall10.png"), wall("a/wall2.png"), wall("Forest.jpg")];

describe("nameOf", () => {
  test("is the last segment of the path", () => {
    expect(nameOf("nature/forest.png")).toBe("forest.png");
    expect(nameOf("forest.png")).toBe("forest.png");
  });
});

describe("byName", () => {
  test("compares numbers in names by value", () => {
    expect(byName(wall("wall2.png"), wall("wall10.png"))).toBeLessThan(0);
  });

  test("ignores the folders of the path", () => {
    expect(byName(wall("z/a.png"), wall("a/b.png"))).toBeLessThan(0);
  });
});

describe("sorted", () => {
  test("keeps the source order without a sort", () => {
    expect(sorted(walls, null)).toBe(walls);
  });

  test("orders names A to Z and Z to A", () => {
    expect(names(sorted(walls, "az"))).toEqual([
      "Forest.jpg",
      "wall2.png",
      "wall10.png",
    ]);
    expect(names(sorted(walls, "za"))).toEqual([
      "wall10.png",
      "wall2.png",
      "Forest.jpg",
    ]);
  });

  test("leaves the given list untouched", () => {
    const before = [...walls];
    sorted(walls, "za");
    expect(walls).toEqual(before);
  });
});
