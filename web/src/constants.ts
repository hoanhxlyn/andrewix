export const APP_NAME = "Andrew Nix";
export const COMMIT_DELAY_MS = 500;

/** Wallpaper sources the gallery offers, in the order it offers them. */
export const SOURCES = ["local", "gruvbox", "tokyonight"] as const;

/** One wallpaper source. */
export type Source = (typeof SOURCES)[number];

/** Orders the gallery can sort by name in, besides the order of its sources. */
export const SORTS = ["asc", "desc"] as const;

/** One sort order of the gallery. */
export type Sort = (typeof SORTS)[number];

/** Ways the gallery can lay out its wallpapers. */
export const WALL_LAYOUTS = ["grid", "table"] as const;

/** One layout of the gallery. */
export type WallLayout = (typeof WALL_LAYOUTS)[number];
