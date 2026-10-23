import { createHighlighter, type Highlighter } from "shiki";

/** Grammars the panes can highlight. Shiki builds them once on first use. */
const LANGS = [
  "nix",
  "lua",
  "json",
  "toml",
  "yaml",
  "bash",
  "markdown",
] as const;

export const THEMES = { light: "catppuccin-latte", dark: "catppuccin-mocha" };

let shared: Promise<Highlighter> | null = null;

/** The one Shiki highlighter of the app, shared by the source and markdown panes. */
export function highlighter(): Promise<Highlighter> {
  shared ??= createHighlighter({
    themes: [THEMES.light, THEMES.dark],
    langs: [...LANGS],
  });
  return shared;
}
