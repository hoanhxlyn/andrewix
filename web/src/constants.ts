export const APP_NAME = "Andrew Nix";
export const COMMIT_DELAY_MS = 500;

/** Wallpaper sources the gallery offers, in the order it offers them. */
export const SOURCES = ["local", "gruvbox", "tokyonight"] as const;

/** One wallpaper source. */
export type Source = (typeof SOURCES)[number];
