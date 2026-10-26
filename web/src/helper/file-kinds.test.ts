import { describe, expect, test } from "bun:test";
import {
  extensionOf,
  isImageFile,
  isMarkdownFile,
  isTextFile,
  languageOf,
} from "./file-kinds";

describe("extensionOf", () => {
  test("is the lowercase text after the last dot", () => {
    expect(extensionOf("config/background/Night.PNG")).toBe("png");
    expect(extensionOf("archive.tar.gz")).toBe("gz");
  });

  test("is empty without a dot", () => {
    expect(extensionOf("modules/Justfile")).toBe("");
  });
});

describe("file kinds", () => {
  test("images are neither text nor markdown", () => {
    expect(isImageFile("a/b.webp")).toBe(true);
    expect(isTextFile("a/b.webp")).toBe(false);
    expect(isMarkdownFile("a/b.webp")).toBe(false);
  });

  test("fonts are not text, and not images either", () => {
    expect(isTextFile("fonts/x.woff2")).toBe(false);
    expect(isImageFile("fonts/x.woff2")).toBe(false);
  });

  test("any other file is text, known or not", () => {
    expect(isTextFile("modules/hosts.nix")).toBe(true);
    expect(isTextFile("config/foo.conf")).toBe(true);
    expect(isTextFile("Justfile")).toBe(true);
  });

  test("markdown is text the pane can also render", () => {
    expect(isMarkdownFile("README.md")).toBe(true);
    expect(isTextFile("README.md")).toBe(true);
  });
});

describe("languageOf", () => {
  test("maps the config file types to Shiki languages", () => {
    expect(languageOf("hosts.nix")).toBe("nix");
    expect(languageOf("ci.yml")).toBe("yaml");
    expect(languageOf("install.sh")).toBe("bash");
    expect(languageOf("README.md")).toBe("markdown");
  });

  test("is undefined for a type without a grammar", () => {
    expect(languageOf("config/foo.conf")).toBeUndefined();
    expect(languageOf("Justfile")).toBeUndefined();
  });
});
