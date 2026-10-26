import { flavors } from "@catppuccin/palette";
import { createGlobalTheme } from "@vanilla-extract/css";

const colors = (flavor: keyof typeof flavors) => {
  const c = flavors[flavor].colors;
  return {
    background: c.mantle.hex,
    surface: c.base.hex,
    surfaceVariant: c.surface0.hex,
    // Between the surface and its variant: the fill of search bars and dialogs.
    surfaceContainerHigh: `color-mix(in srgb, ${c.surface0.hex} 70%, ${c.base.hex})`,
    onSurface: c.text.hex,
    onSurfaceVariant: c.subtext1.hex,
    outline: c.overlay1.hex,
    primary: c.mauve.hex,
    onPrimary: c.base.hex,
    primaryContainer: `color-mix(in srgb, ${c.mauve.hex} 20%, ${c.base.hex})`,
    onPrimaryContainer: c.text.hex,
    // The palette has no secondary hue, so a muted primary over the variant surface stands in.
    secondaryContainer: `color-mix(in srgb, ${c.mauve.hex} 24%, ${c.surface0.hex})`,
    onSecondaryContainer: c.text.hex,
  };
};

const space = { xs: "4px", sm: "8px", md: "12px", lg: "16px", xl: "24px" };

export const breakpoints = {
  medium: "(min-width: 600px)",
  expanded: "(min-width: 840px)",
};

// Layout grid columns per window class. Compact is the default, the others apply from their breakpoint.
export const columns = { compact: 4, medium: 8, expanded: 12 } as const;

// Tree sidebar width in pixels: its default, the range it can be dragged to, and one arrow key step.
export const sidebarWidth = {
  initial: 300,
  min: 200,
  max: 600,
  step: 16,
} as const;

// M3 circular progress indicator, in pixels since they size its SVG: the diameter and the width
// of its arc.
export const progress = { size: 48, stroke: 4 } as const;

// Wallpaper gallery, in pixels for the virtualized layouts that position its items from script:
// cards per row in each window class, the narrowest card, the gap between cards, the heights and
// fixed column widths of the table, the height of the row holding the loading indicator, and how
// many wallpapers each batch adds to the list.
export const gallery = {
  cardsPerRow: { compact: 1, medium: 3, expanded: 6 },
  minCardWidth: 112,
  gap: Number.parseInt(space.md, 10),
  rowHeight: 56,
  headingHeight: 48,
  pictureColumn: 96,
  sourceColumn: 112,
  favoriteColumn: 72,
  loaderHeight: progress.size + 2 * Number.parseInt(space.sm, 10),
  batchSize: 48,
} as const;

// Transition length in milliseconds and its easing; a number too, for animations run from script.
// Emphasized is the M3 curve for motion the user is meant to notice: dialogs, picture reveals.
// Progress is the M3 indeterminate circle: the time its arc takes to grow or shrink, the time of
// one turn, and the curve of the arc.
export const motion = {
  duration: 200,
  easing: "ease",
  emphasized: { duration: 300, easing: "cubic-bezier(0.2, 0, 0, 1)" },
  progress: { arc: 1333, turn: 1568, easing: "cubic-bezier(0.4, 0, 0.2, 1)" },
} as const;

const shared = {
  space,
  layout: {
    columns: String(columns.compact),
    margin: space.lg,
    gutter: space.lg,
  },
  size: {
    icon: "24px",
    iconSmall: "16px",
    iconChip: "18px",
    iconLarge: "48px",
    prose: "80ch",
    control: "40px",
    controlSmall: "32px",
    controlLarge: "56px",
    // Smallest area a finger can reliably hit, whatever the size of the control drawn in it.
    touchTarget: "48px",
    progress: `${progress.size}px`,
    sidebar: `${sidebarWidth.initial}px`,
  },
  shape: {
    extraSmall: "4px",
    small: "8px",
    medium: "12px",
    large: "20px",
    extraLarge: "28px",
    full: "999px",
  },
  border: { outline: "1px", focusRing: "2px", indicator: "2px" },
  layer: { raised: "1", overlay: "2" },
  motion: {
    duration: `${motion.duration}ms`,
    easing: motion.easing,
    emphasizedDuration: `${motion.emphasized.duration}ms`,
    emphasizedEasing: motion.emphasized.easing,
    progressArc: `${motion.progress.arc}ms`,
    progressTurn: `${motion.progress.turn}ms`,
    progressEasing: motion.progress.easing,
  },
  state: {
    hover: "0.08",
    focus: "0.12",
    pressed: "0.12",
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
    level3: "0 1px 3px rgb(0 0 0 / 0.3), 0 4px 8px 3px rgb(0 0 0 / 0.15)",
  },
};

export const dark = {
  color: colors("mocha"),
  elevation: {
    level1: "0 1px 3px 1px rgb(0 0 0 / 0.5)",
    level2: "0 2px 6px 2px rgb(0 0 0 / 0.5)",
    level3: "0 4px 8px 3px rgb(0 0 0 / 0.5)",
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
