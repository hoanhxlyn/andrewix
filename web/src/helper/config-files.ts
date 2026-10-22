/** Raw text of every file of the config, loaded on demand as chunks. */
const sources: Record<string, () => Promise<unknown>> = {
  ...import.meta.glob("../../modules/**/*", {
    query: "?raw",
    import: "default",
  }),
  ...import.meta.glob("../../config/**/*", {
    query: "?raw",
    import: "default",
  }),
};

const loaders = new Map(
  Object.entries(sources).map(([path, load]) => [
    path.replace("../../", ""),
    load as () => Promise<string>,
  ]),
);

/** Extensions that are not source text, so the peek pane cannot show them. */
const BINARY = new Set([
  "png",
  "jpg",
  "jpeg",
  "gif",
  "webp",
  "ico",
  "woff",
  "woff2",
  "ttf",
  "otf",
]);

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

function extensionOf(path: string): string {
  const dot = path.lastIndexOf(".");
  return dot === -1 ? "" : path.slice(dot + 1).toLowerCase();
}

/** Whether a config file is text the peek pane can show. */
export function isTextFile(path: string): boolean {
  return !BINARY.has(extensionOf(path));
}

/** Shiki language of a config file, or undefined when it has no bundled grammar. */
export function languageOf(path: string): string | undefined {
  return LANGUAGES[extensionOf(path)];
}

/** Loader for the source of a config file, or null when the path is not one of its files. */
export function loadSource(path: string): (() => Promise<string>) | null {
  return loaders.get(path) ?? null;
}
