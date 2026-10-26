import { describe, expect, test } from "bun:test";
import type { FolderNode } from "./FolderTree";
import {
  ancestorsOf,
  childPath,
  filePaths,
  matches,
  toggled,
} from "./tree-paths";

const tree: FolderNode = {
  kind: "folder",
  name: "",
  children: [
    { kind: "file", name: "flake.nix" },
    {
      kind: "folder",
      name: "modules",
      children: [
        { kind: "file", name: "hosts.nix" },
        {
          kind: "folder",
          name: "core",
          children: [{ kind: "file", name: "Sound.nix" }],
        },
      ],
    },
  ],
};

describe("childPath", () => {
  test("joins with a slash below the root", () => {
    expect(childPath("", "modules")).toBe("modules");
    expect(childPath("modules", "core")).toBe("modules/core");
  });
});

describe("filePaths", () => {
  test("lists every file by its repository path", () => {
    expect(filePaths(tree, "")).toEqual([
      "flake.nix",
      "modules/hosts.nix",
      "modules/core/Sound.nix",
    ]);
  });
});

describe("matches", () => {
  test("a folder matches when a file below it does", () => {
    expect(matches(tree, "", "sound")).toBe(true);
    expect(matches(tree, "", "missing")).toBe(false);
  });

  test("the query is matched against the whole path, in lowercase", () => {
    expect(
      matches({ kind: "file", name: "Sound.nix" }, "core/Sound.nix", "core/s"),
    ).toBe(true);
  });
});

describe("ancestorsOf", () => {
  test("is every folder above the paths, once", () => {
    expect(ancestorsOf(["a/b/c.nix", "a/d.nix", "e.nix"])).toEqual(
      new Set(["a", "a/b"]),
    );
  });
});

describe("toggled", () => {
  test("adds a missing key and removes a present one, as a new set", () => {
    const set = new Set(["a"]);
    expect(toggled(set, "b")).toEqual(new Set(["a", "b"]));
    expect(toggled(set, "a")).toEqual(new Set());
    expect(set).toEqual(new Set(["a"]));
  });
});
