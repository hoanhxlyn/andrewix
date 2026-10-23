/**
 * Extensions of images, shown as pictures instead of source. The image glob below repeats them,
 * since Vite needs the pattern as a literal.
 */
const IMAGES = new Set(["png", "jpg", "jpeg", "gif", "webp", "ico"]);

/**
 * Extensions that are not source text, so the source pane cannot show them. The loader glob below
 * repeats them as its exclude pattern, since Vite needs the pattern as a literal.
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

function extensionOf(path: string): string {
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

/** Prefix Vite gives glob keys for paths above the project root, stripped to get the repository path. */
const ROOT = "../";

/**
 * One lazy loader per text file; each file becomes its own chunk, fetched on first use. Every file
 * that is not binary is included, so a new kind of text file (`.txt`, `.conf`) shows without a
 * change here.
 */
const loaders = Object.fromEntries(
  Object.entries(
    import.meta.glob<string>(
      [
        "/../{modules,config}/**/*",
        "!/../{modules,config}/**/*.{png,jpg,jpeg,gif,webp,ico,woff,woff2,ttf,otf}",
      ],
      { query: "?raw", import: "default" },
    ),
  ).map(([key, load]) => [key.slice(ROOT.length), load]),
);

/** Loads the source of a config file, or null when the path is not one of its files. */
export async function sourceOf(path: string): Promise<string | null> {
  const load = loaders[path];
  return load ? await load() : null;
}

/**
 * Built URL of every image, eager since each is only a string. The image itself is fetched by the
 * browser when it is shown.
 */
const imageUrls: Record<string, string> = Object.fromEntries(
  Object.entries(
    import.meta.glob<string>(
      "/../{modules,config}/**/*.{png,jpg,jpeg,gif,webp,ico}",
      { query: "?url", import: "default", eager: true },
    ),
  ).map(([key, url]) => [key.slice(ROOT.length), url]),
);

/** Built URL of a config image, or null when the path is not one of its images. */
export function imageUrlOf(path: string): string | null {
  return imageUrls[path] ?? null;
}
