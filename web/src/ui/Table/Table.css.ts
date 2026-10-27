import { style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

const focusRing = `${vars.border.focusRing} solid ${vars.color.primary}`;

/** Table that scrolls inside its container, its header staying on top. */
export const table = style(
  inComponents({
    ...text.body,
    overflow: "auto",
    border: `${vars.border.outline} solid ${vars.color.outlineVariant}`,
    borderRadius: vars.shape.extraSmall,
    color: vars.color.onSurface,
    outline: "none",
    selectors: { "&[data-focus-visible]": { outline: focusRing } },
  }),
);

/**
 * One column heading, on the surface so the rows scroll under it. A sortable one is pressable and
 * shows the arrow of the order it is in.
 */
export const column = style([
  stateLayer,
  inComponents({
    ...text.label,
    display: "flex",
    alignItems: "center",
    gap: vars.space.xs,
    height: "100%",
    paddingInline: vars.space.md,
    background: vars.color.surface,
    borderBottom: `${vars.border.outline} solid ${vars.color.outlineVariant}`,
    color: vars.color.onSurfaceVariant,
    outline: "none",
    selectors: {
      "&[data-allows-sorting]": { cursor: "pointer" },
      "&[data-focus-visible]": {
        outline: focusRing,
        outlineOffset: `-${vars.border.focusRing}`,
      },
    },
  }),
]);

/** Text of a column heading, cut when the column is too narrow. */
export const heading = style(
  inComponents({
    minWidth: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
  }),
);

/** Arrow of the sorted column, pointing up while the order runs A to Z. */
export const sortIndicator = style(
  inComponents({
    flexShrink: 0,
    fontSize: vars.size.iconSmall,
    // The shared chevron points right; half a turn either way makes it point up or down.
    transform: "rotate(-90deg)",
    transition: `transform ${vars.motion.duration} ${vars.motion.easing}`,
    "@media": {
      "(prefers-reduced-motion: reduce)": { transition: "none" },
    },
  }),
);

/** The arrow of the sorted column while the order runs Z to A. */
export const sortIndicatorDescending = style(
  inComponents({ transform: "rotate(90deg)" }),
);

/**
 * One row, with the usual hover and pressed feedback and a divider under it.
 */
export const row = style([
  stateLayer,
  inComponents({
    borderBottom: `${vars.border.outline} solid ${vars.color.outlineVariant}`,
    outline: "none",
    selectors: {
      // React Aria marks a row hovered only when pressing it does something.
      "&[data-hovered]": { cursor: "pointer" },
      // Inset, since the scrolling table would clip a ring drawn outside the row.
      "&[data-focus-visible]": {
        outline: focusRing,
        outlineOffset: `-${vars.border.focusRing}`,
      },
    },
  }),
]);

/** One cell, its content centred vertically and cut when too wide. */
export const cell = style(
  inComponents({
    display: "flex",
    alignItems: "center",
    gap: vars.space.sm,
    height: "100%",
    minWidth: 0,
    paddingInline: vars.space.md,
    overflow: "hidden",
    outline: "none",
    selectors: {
      "&[data-focus-visible]": {
        outline: focusRing,
        outlineOffset: `-${vars.border.focusRing}`,
      },
    },
  }),
);

/** Row at the end of the table holding the indicator of the rows still to come. */
export const loader = style(
  inComponents({
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  }),
);
