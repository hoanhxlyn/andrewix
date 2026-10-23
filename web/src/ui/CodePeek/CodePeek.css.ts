import { globalStyle, keyframes, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

/** Scrollable source of the shown file. */
export const code = style(
  inComponents({
    margin: 0,
    background: vars.color.surface,
    color: vars.color.onSurface,
    // The gutter needs the inline-start edge: its sticky numbers clamp at the content edge.
    paddingBlock: vars.space.md,
    paddingInlineEnd: vars.space.md,
    paddingInlineStart: 0,
    // Isolated so the gutter's z-index stays inside the block instead of the tree pane's overlay.
    isolation: "isolate",
    flex: 1,
    minHeight: 0,
    overflow: "auto",
    fontFamily: vars.typeface.mono,
    fontSize: vars.type.body.size,
    lineHeight: vars.type.body.lineHeight,
  }),
);

// Shiki stamps light-theme colors inline on each token span; the dark pair lives in
// --shiki-dark, so only an !important rule can switch it per theme. Line numbers
// carry no shiki colors and keep their own.
globalStyle(`[data-theme="dark"] .${code} span:not([data-num])`, {
  color: "var(--shiki-dark) !important",
});

/** Line number in the gutter, sticky so it stays while the code scrolls sideways. */
export const num = style(
  inComponents({
    position: "sticky",
    left: 0,
    // Tokens paint after the number; only z-index keeps the gutter above the code.
    zIndex: 1,
    display: "inline-block",
    // Content box, so the width is the digits alone and the padding and divider come on top.
    boxSizing: "content-box",
    width: "3ch", // shortcut: clips past 999 lines, widen to 4ch when a config file outgrows it
    paddingInlineStart: vars.space.md,
    paddingInlineEnd: vars.space.sm,
    marginInlineEnd: vars.space.md,
    borderInlineEnd: `${vars.border.outline} solid ${vars.color.outline}`,
    textAlign: "right",
    userSelect: "none",
    color: vars.color.onSurfaceVariant,
    background: vars.color.surface,
  }),
);

/** Aspect reference in the source that opens the file defining the aspect. */
export const link = style(
  inComponents({
    color: "inherit",
    textDecorationLine: "underline",
    textDecorationStyle: "dotted",
    textUnderlineOffset: vars.border.focusRing,
    borderRadius: vars.shape.small,
    selectors: {
      "&:hover": { textDecorationStyle: "solid" },
      "&:focus-visible": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
      },
    },
  }),
);

const pulse = keyframes({
  "0%, 100%": { opacity: 1 },
  "50%": { opacity: 0.4 },
});

/** Placeholder block standing in for the source while a file loads. */
export const skeleton = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    gap: vars.space.sm,
    paddingInline: vars.space.md,
    "@media": {
      "(prefers-reduced-motion: no-preference)": {
        animation: `${pulse} 1.2s ${vars.motion.easing} infinite`,
      },
    },
  }),
);

/** One placeholder line of the loading skeleton; widths vary by position to look like code. */
export const skeletonLine = style(
  inComponents({
    // Bar plus gap add up to one code line, so the skeleton has the height of the source.
    height: `calc(${vars.type.body.lineHeight} - ${vars.space.sm})`,
    borderRadius: vars.shape.small,
    background: vars.color.surfaceVariant,
    selectors: {
      "&:nth-child(4n+1)": { width: "60%" },
      "&:nth-child(4n+2)": { width: "85%" },
      "&:nth-child(4n+3)": { width: "40%" },
      "&:nth-child(4n)": { width: "70%" },
    },
  }),
);

/** Source block whose long lines wrap to the pane instead of scrolling sideways. */
export const wrapped = style({});

/** Text of one source line, after its number. */
export const content = style({});

// Wrapped lines keep a hanging indent: the number stays in its column and the text wraps
// beside it instead of under it.
globalStyle(`${wrapped} > div`, inComponents({ display: "flex" }));

globalStyle(
  `${wrapped} ${content}`,
  inComponents({
    flex: 1,
    minWidth: 0,
    whiteSpace: "pre-wrap",
    overflowWrap: "anywhere",
  }),
);
