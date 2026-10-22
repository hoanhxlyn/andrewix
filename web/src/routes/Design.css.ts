import { style, styleVariants } from "@vanilla-extract/css";
import { sprinkles } from "../styles/sprinkles.css";
import { text, vars } from "../styles/tokens.css";

/** Section heading in the design catalog. */
export const heading = style([text.title, { margin: 0 }]);

/** Small label above a catalog sample. */
export const caption = style([
  text.label,
  { margin: 0, color: vars.color.onSurfaceVariant },
]);

/** Grid that lays out the color swatches. */
export const grid = style({
  display: "grid",
  gridTemplateColumns: `repeat(auto-fill, minmax(calc(${vars.space.xl} * 6), 1fr))`,
  gap: vars.space.lg,
});

/** One color swatch together with its label. */
export const swatch = sprinkles({ display: "grid", gap: "xs" });

/** Color preview box inside a swatch. */
export const swatchColor = style({
  height: `calc(${vars.space.xl} * 2)`,
  borderRadius: vars.shape.small,
  border: `${vars.border.outline} solid ${vars.color.outline}`,
});

/** Bar whose width shows a space step. */
export const spaceBar = style({
  height: vars.space.md,
  borderRadius: vars.shape.small,
  background: vars.color.primary,
});

/** Sample tile for the shape and elevation examples. */
export const sample = style({
  width: `calc(${vars.space.xl} * 3)`,
  height: `calc(${vars.space.xl} * 3)`,
  background: vars.color.primaryContainer,
  color: vars.color.onPrimaryContainer,
  display: "grid",
  placeItems: "center",
  ...text.label,
});

/** Container that places the light and dark previews side by side. */
export const themes = style({
  display: "grid",
  gridTemplateColumns: `repeat(auto-fit, minmax(calc(${vars.space.xl} * 14), 1fr))`,
  gap: vars.space.lg,
});

/** Sample text for each type role. */
export const typeSample = styleVariants(vars.type, (_value, role) => [
  text[role],
  { margin: 0 },
]);

/** Cell that shows one column of the layout grid. */
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
