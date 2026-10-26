import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Clickable area of a checkbox: the box and its label. */
export const checkbox = style(
  inComponents({
    ...text.label,
    display: "inline-flex",
    alignItems: "center",
    gap: vars.space.xs,
    // The box is small, so the whole label is the touch target, at least as tall as a finger needs.
    minHeight: vars.size.touchTarget,
    color: vars.color.onSurfaceVariant,
    cursor: "pointer",
    userSelect: "none",
  }),
);

/** Box that shows whether the checkbox is selected. */
export const box = style(
  inComponents({
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
    width: vars.size.iconSmall,
    height: vars.size.iconSmall,
    // Half the small shape: the full radius would turn a box this size into a circle.
    borderRadius: `calc(${vars.shape.small} / 2)`,
    border: `${vars.border.outline} solid ${vars.color.outline}`,
    selectors: {
      [`${checkbox}[data-selected] &`]: {
        background: vars.color.primary,
        borderColor: vars.color.primary,
        color: vars.color.onPrimary,
      },
      [`${checkbox}[data-focus-visible] &`]: {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
        outlineOffset: vars.border.focusRing,
      },
    },
  }),
);

globalStyle(
  `${box} > svg`,
  inComponents({ width: vars.size.iconSmall, height: vars.size.iconSmall }),
);
