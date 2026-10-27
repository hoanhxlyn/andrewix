import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Material segmented button: one outlined pill split into segments. */
export const group = style(
  inComponents({
    display: "inline-flex",
    flexShrink: 0,
    height: vars.size.control,
    borderRadius: vars.shape.full,
    border: `${vars.border.outline} solid ${vars.color.outline}`,
  }),
);

/** One segment; the selected one is filled with the secondary container. */
export const segment = style([
  stateLayer,
  inComponents({
    ...text.label,
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    gap: vars.space.sm,
    // Segments share their row evenly, as Material sizes them, whatever each one holds.
    flex: 1,
    minWidth: 0,
    paddingInline: vars.space.md,
    appearance: "none",
    border: "none",
    background: "transparent",
    color: vars.color.onSurface,
    cursor: "pointer",
    selectors: {
      // The outline between two segments, drawn by the later one.
      "& + &": {
        borderInlineStart: `${vars.border.outline} solid ${vars.color.outline}`,
      },
      "&:first-child": {
        borderStartStartRadius: vars.shape.full,
        borderEndStartRadius: vars.shape.full,
      },
      "&:last-child": {
        borderStartEndRadius: vars.shape.full,
        borderEndEndRadius: vars.shape.full,
      },
      "&[data-selected]": {
        background: vars.color.secondaryContainer,
        color: vars.color.onSecondaryContainer,
      },
    },
  }),
]);

globalStyle(
  `${segment} > svg`,
  inComponents({ width: vars.size.iconChip, height: vars.size.iconChip }),
);
