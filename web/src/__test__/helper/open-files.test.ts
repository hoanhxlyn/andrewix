import { describe, expect, test } from "bun:test";
import { labelOf, openPaths, shownAfterClose } from "@/helper/open-files";

describe("openPaths", () => {
  const exists = (path: string) => path !== "gone.nix";

  test("adds the file of the link after the stored tabs", () => {
    expect(openPaths(["a.nix"], "b.nix", exists)).toEqual(["a.nix", "b.nix"]);
  });

  test("drops repeated and missing paths", () => {
    expect(openPaths(["a.nix", "gone.nix", "a.nix"], "a.nix", exists)).toEqual([
      "a.nix",
    ]);
    expect(openPaths([], "gone.nix", exists)).toEqual([]);
  });
});

describe("shownAfterClose", () => {
  const open = ["a", "b", "c"];

  test("shows the right neighbour of the closed shown tab", () => {
    expect(shownAfterClose(open, "b", "b")).toBe("c");
    expect(shownAfterClose(open, "a", "a")).toBe("b");
  });

  test("shows the new last tab when the last one closes", () => {
    expect(shownAfterClose(open, "c", "c")).toBe("b");
  });

  test("shows nothing once the only tab closes", () => {
    expect(shownAfterClose(["a"], "a", "a")).toBeNull();
  });

  test("keeps the shown file when another tab closes", () => {
    expect(shownAfterClose(open, "a", "c")).toBe("c");
    expect(shownAfterClose(open, "a", null)).toBeNull();
  });
});

describe("labelOf", () => {
  test("is the file name when it is unique among the tabs", () => {
    expect(labelOf("modules/hosts.nix", ["modules/hosts.nix", "a/b.nix"])).toBe(
      "hosts.nix",
    );
  });

  test("adds the folder when another tab shares the name", () => {
    const open = ["modules/core/a/default.nix", "modules/core/b/default.nix"];
    expect(labelOf("modules/core/a/default.nix", open)).toBe("a/default.nix");
  });
});
