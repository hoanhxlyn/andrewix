import { globalStyle, style } from "@vanilla-extract/css";
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
