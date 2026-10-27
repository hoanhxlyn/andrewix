export const APP_NAME = "Andrew Nix";
export const COMMIT_DELAY_MS = 500;

/** Wallpaper sources the gallery offers, in the order it offers them. */
export const SOURCES = [
  "local",
  "catppuccin",
  "gruvbox",
  "tokyonight",
] as const;

/** One wallpaper source. */
export type Source = (typeof SOURCES)[number];

/** Columns the gallery can sort by; the picture has no order of its own. */
export const SORT_COLUMNS = ["name", "source", "favorite"] as const;

/** One column the gallery can sort by. */
export type SortColumn = (typeof SORT_COLUMNS)[number];

/** Order a column can be in, A to Z (asc) or Z to A (desc). */
export const SORT_ORDERS = ["asc", "desc"] as const;

/** One order of a column. */
export type SortOrder = (typeof SORT_ORDERS)[number];

/** A column and the order it is in; without one the gallery keeps the order of its sources. */
export interface Sort {
  column: SortColumn;
  order: SortOrder;
}

/** Ways the gallery can lay out its wallpapers. */
export const WALL_LAYOUTS = ["grid", "table"] as const;

/** One layout of the gallery. */
export type WallLayout = (typeof WALL_LAYOUTS)[number];
