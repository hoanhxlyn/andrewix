import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Floating label with extra information about the element it points at. */
export const tooltip = style(
  inComponents({
    ...text.label,
    paddingBlock: vars.space.xs,
    paddingInline: vars.space.sm,
    borderRadius: vars.shape.small,
    background: vars.color.onSurface,
    color: vars.color.surface,
    boxShadow: vars.elevation.level2,
    pointerEvents: "none",
  }),
);
