import { style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

const focusRing = `${vars.border.focusRing} solid ${vars.color.primary}`;

/** Table that scrolls inside its container, its header staying on top. */
export const table = style(
  inComponents({
    ...text.body,
    overflow: "auto",
    color: vars.color.onSurface,
    outline: "none",
    selectors: { "&[data-focus-visible]": { outline: focusRing } },
  }),
);

/** One column heading, on the surface so the rows scroll under it. */
export const column = style(
  inComponents({
    ...text.label,
    display: "flex",
    alignItems: "center",
    height: "100%",
    paddingInline: vars.space.md,
    background: vars.color.surface,
    borderBottom: `${vars.border.outline} solid ${vars.color.outline}`,
    color: vars.color.onSurfaceVariant,
    outline: "none",
    selectors: {
      "&[data-focus-visible]": {
        outline: focusRing,
        outlineOffset: `-${vars.border.focusRing}`,
      },
    },
  }),
);

/** One row, with the usual hover and pressed feedback and a divider under it. */
export const row = style([
  stateLayer,
  inComponents({
    borderBottom: `${vars.border.outline} solid ${vars.color.surfaceVariant}`,
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
