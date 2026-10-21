import { style, styleVariants } from "@vanilla-extract/css";
import { sprinkles } from "../styles/sprinkles.css";
import { text, vars } from "../styles/tokens.css";

export const heading = style([text.title, { margin: 0 }]);

export const caption = style([
  text.label,
  { margin: 0, color: vars.color.onSurfaceVariant },
]);

export const grid = style({
  display: "grid",
  gridTemplateColumns: `repeat(auto-fill, minmax(calc(${vars.space.xl} * 6), 1fr))`,
  gap: vars.space.lg,
});

export const swatch = sprinkles({ display: "grid", gap: "xs" });

export const swatchColor = style({
  height: `calc(${vars.space.xl} * 2)`,
  borderRadius: vars.shape.small,
  border: `${vars.border.outline} solid ${vars.color.outline}`,
});

export const spaceBar = style({
  height: vars.space.md,
  borderRadius: vars.shape.small,
  background: vars.color.primary,
});

export const sample = style({
  width: `calc(${vars.space.xl} * 3)`,
  height: `calc(${vars.space.xl} * 3)`,
  background: vars.color.primaryContainer,
  color: vars.color.onPrimaryContainer,
  display: "grid",
  placeItems: "center",
  ...text.label,
});

export const themes = style({
  display: "grid",
  gridTemplateColumns: `repeat(auto-fit, minmax(calc(${vars.space.xl} * 14), 1fr))`,
  gap: vars.space.lg,
});

export const typeSample = styleVariants(vars.type, (_value, role) => [
  text[role],
  { margin: 0 },
]);

export const cell = style([
  text.label,
  {
    display: "grid",
    placeItems: "center",
    padding: vars.space.md,
    borderRadius: vars.shape.small,
    background: vars.color.primaryContainer,
    color: vars.color.onPrimaryContainer,
  },
]);
