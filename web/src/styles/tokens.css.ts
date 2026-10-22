import { flavors } from "@catppuccin/palette";
import { createGlobalTheme } from "@vanilla-extract/css";

const colors = (flavor: keyof typeof flavors) => {
  const c = flavors[flavor].colors;
  return {
    background: c.mantle.hex,
    surface: c.base.hex,
    surfaceVariant: c.surface0.hex,
    onSurface: c.text.hex,
    onSurfaceVariant: c.subtext1.hex,
    outline: c.overlay1.hex,
    primary: c.mauve.hex,
    onPrimary: c.base.hex,
    primaryContainer: `color-mix(in srgb, ${c.mauve.hex} 20%, ${c.base.hex})`,
    onPrimaryContainer: c.text.hex,
  };
};

const space = { xs: "4px", sm: "8px", md: "12px", lg: "16px", xl: "24px" };

export const breakpoints = {
  medium: "(min-width: 600px)",
  expanded: "(min-width: 840px)",
};

// Layout grid columns per window class. Compact is the default, the others apply from their breakpoint.
export const columns = { compact: 4, medium: 8, expanded: 12 } as const;

const shared = {
  space,
  layout: {
    columns: String(columns.compact),
    margin: space.lg,
    gutter: space.lg,
  },
  size: { icon: "24px", control: "40px" },
  shape: { small: "8px", medium: "12px", large: "20px", full: "999px" },
  border: { outline: "1px", focusRing: "2px" },
  layer: { raised: "1" },
  motion: { duration: "200ms", easing: "ease" },
  state: {
    hover: "0.08",
    focus: "0.1",
    pressed: "0.1",
    disabledContainer: "0.12",
    disabledContent: "0.38",
  },
  typeface: {
    body: "'Roboto Variable', system-ui, sans-serif",
    mono: "'Roboto Mono Variable', ui-monospace, monospace",
  },
  type: {
    headline: {
      size: "2rem",
      lineHeight: "2.5rem",
      tracking: "0rem",
      weight: "400",
    },
    body: {
      size: "1rem",
      lineHeight: "1.5rem",
      tracking: "0.03125rem",
      weight: "400",
    },
    title: {
      size: "1.375rem",
      lineHeight: "1.75rem",
      tracking: "0rem",
      weight: "400",
    },
    label: {
      size: "0.875rem",
      lineHeight: "1.25rem",
      tracking: "0.00625rem",
      weight: "500",
    },
  },
};

// Theme-dependent tokens. Light is the default; its shape defines what dark must provide.
export const light = {
  color: colors("latte"),
  elevation: {
    level1: "0 1px 2px rgb(0 0 0 / 0.3), 0 1px 3px 1px rgb(0 0 0 / 0.15)",
    level2: "0 1px 2px rgb(0 0 0 / 0.3), 0 2px 6px 2px rgb(0 0 0 / 0.15)",
  },
};

export const dark = {
  color: colors("mocha"),
  elevation: {
    level1: "0 1px 3px 1px rgb(0 0 0 / 0.5)",
    level2: "0 2px 6px 2px rgb(0 0 0 / 0.5)",
  },
};

export const themeVars = createGlobalTheme(":root", light);
const sharedVars = createGlobalTheme(":root", shared);

export const vars = { ...themeVars, ...sharedVars };

/** Style properties per type scale role, to spread into a style. */
export const text = {
  headline: {
    fontSize: vars.type.headline.size,
    lineHeight: vars.type.headline.lineHeight,
    letterSpacing: vars.type.headline.tracking,
    fontWeight: vars.type.headline.weight,
  },
  body: {
    fontSize: vars.type.body.size,
    lineHeight: vars.type.body.lineHeight,
    letterSpacing: vars.type.body.tracking,
    fontWeight: vars.type.body.weight,
  },
  title: {
    fontSize: vars.type.title.size,
    lineHeight: vars.type.title.lineHeight,
    letterSpacing: vars.type.title.tracking,
    fontWeight: vars.type.title.weight,
  },
  label: {
    fontSize: vars.type.label.size,
    lineHeight: vars.type.label.lineHeight,
    letterSpacing: vars.type.label.tracking,
    fontWeight: vars.type.label.weight,
  },
};
