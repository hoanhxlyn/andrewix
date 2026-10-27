/**
 * Extensions of images, shown as pictures instead of source. The image glob in `config-files.ts`
 * repeats them, since Vite needs the pattern as a literal.
 */
const IMAGES = new Set(["png", "jpg", "jpeg", "gif", "webp", "ico"]);

/**
 * Extensions that are not source text, so the source pane cannot show them. The loader glob in
 * `config-files.ts` repeats them as its exclude pattern, since Vite needs the pattern as a literal.
 */
const BINARY = new Set([...IMAGES, "woff", "woff2", "ttf", "otf"]);

/** Shiki language ids for the file types the config uses. Others render unhighlighted. */
const LANGUAGES: Record<string, string> = {
  nix: "nix",
  lua: "lua",
  json: "json",
  toml: "toml",
  yaml: "yaml",
  yml: "yaml",
  sh: "bash",
  md: "markdown",
};

/** Lowercase extension of a path, or an empty string when it has none. */
export function extensionOf(path: string): string {
  const dot = path.lastIndexOf(".");
  return dot === -1 ? "" : path.slice(dot + 1).toLowerCase();
}

/** Whether a config file is text the peek pane can show. */
export function isTextFile(path: string): boolean {
  return !BINARY.has(extensionOf(path));
}

/** Whether a config file is an image the pane shows as a picture. */
export function isImageFile(path: string): boolean {
  return IMAGES.has(extensionOf(path));
}

/** Whether a config file is markdown, which the pane can also show rendered. */
export function isMarkdownFile(path: string): boolean {
  return extensionOf(path) === "md";
}

/** Shiki language of a config file, or undefined when it has no bundled grammar. */
export function languageOf(path: string): string | undefined {
  return LANGUAGES[extensionOf(path)];
}
