import { style, styleVariants } from "@vanilla-extract/css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Section heading in the design catalog. */
export const heading = style([text.title, { margin: 0 }]);

/** Small label above a catalog sample. */
export const caption = style([
  text.label,
  sprinkles({ color: "onSurfaceVariant" }),
  { margin: 0 },
]);

/** Grid that lays out the color swatches. */
export const grid = style([
  sprinkles({ display: "grid", gap: "lg" }),
  {
    gridTemplateColumns: `repeat(auto-fill, minmax(calc(${vars.space.xl} * 6), 1fr))`,
  },
]);

/** One color swatch together with its label. */
export const swatch = sprinkles({ display: "grid", gap: "xs" });

/** Color preview box inside a swatch. */
export const swatchColor = style([
  sprinkles({ borderRadius: "small", border: "outline" }),
  { height: `calc(${vars.space.xl} * 2)` },
]);

/** Bar whose width shows a space step. */
export const spaceBar = style([
  sprinkles({ borderRadius: "small", background: "primary" }),
  { height: vars.space.md },
]);

/** Sample tile for the shape and elevation examples. */
export const sample = style([
  text.label,
  sprinkles({
    display: "grid",
    background: "primaryContainer",
    color: "onPrimaryContainer",
  }),
  {
    width: `calc(${vars.space.xl} * 3)`,
    height: `calc(${vars.space.xl} * 3)`,
    placeItems: "center",
  },
]);

/** Container that places the light and dark previews side by side. */
export const themes = style([
  sprinkles({ display: "grid", gap: "lg" }),
  {
    gridTemplateColumns: `repeat(auto-fit, minmax(calc(${vars.space.xl} * 14), 1fr))`,
  },
]);

/** Sample text for each type role. */
export const typeSample = styleVariants(vars.type, (_value, role) => [
  text[role],
  { margin: 0 },
]);

/** Cell that shows one column of the layout grid. */
export const cell = style([
  text.label,
  sprinkles({
    display: "grid",
    padding: "md",
    borderRadius: "small",
    background: "primaryContainer",
    color: "onPrimaryContainer",
  }),
  { placeItems: "center" },
]);
