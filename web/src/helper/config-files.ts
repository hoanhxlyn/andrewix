export {
  isImageFile,
  isMarkdownFile,
  isTextFile,
  languageOf,
} from "@/helper/file-kinds";

/** Prefix Vite gives glob keys for paths above the project root, stripped to get the repository path. */
const ROOT = "../";

/**
 * One lazy loader per text file; each file becomes its own chunk, fetched on first use. Every file
 * that is not binary is included, so a new kind of text file (`.txt`, `.conf`) shows without a
 * change here. The exclude pattern repeats `BINARY` of `file-kinds.ts`.
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
 * Built URL of every config image, eager since each is only a string. The image itself is fetched by
 * the browser when it is shown. The pattern repeats `IMAGES` of `file-kinds.ts`.
 */
const imageUrls: Record<string, string> = Object.fromEntries(
  Object.entries(
    import.meta.glob<string>(
      "/../{modules,config}/**/*.{png,jpg,jpeg,gif,webp,ico}",
      { query: "?url", import: "default", eager: true },
    ),
  ).map(([key, url]) => [key.slice(ROOT.length), url]),
);

/** Repository path of every config image. */
export const imagePaths: string[] = Object.keys(imageUrls);

/** Built URL of a config image, or null when the path is not one of its images. */
export function imageUrlOf(path: string): string | null {
  return imageUrls[path] ?? null;
}
