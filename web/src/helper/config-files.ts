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

/** Prefix Vite gives glob keys for paths above the project root, stripped to get the repository path. */
const ROOT = "../";

/** One lazy loader per text file; each file becomes its own chunk, fetched on first use. */
const loaders = Object.fromEntries(
  Object.entries(
    import.meta.glob<string>(
      "/../{modules,config}/**/*.{fish,json,lua,md,nix,sh,toml,yaml,yml}",
      { query: "?raw", import: "default" },
    ),
  ).map(([key, load]) => [key.slice(ROOT.length), load]),
);

/** Loads the source of a config file, or null when the path is not one of its files. */
export async function sourceOf(path: string): Promise<string | null> {
  const load = loaders[path];
  return load ? await load() : null;
}
