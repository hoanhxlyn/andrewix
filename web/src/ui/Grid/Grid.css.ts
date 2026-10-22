import { style } from "@vanilla-extract/css";
import { inComponents } from "../../styles/layers.css";
import { sprinkles } from "../../styles/sprinkles.css";
import { vars } from "../../styles/tokens.css";

/** Layout grid for page content. */
export const grid = style([
  sprinkles({ display: "grid" }),
  inComponents({
    gridTemplateColumns: `repeat(${vars.layout.columns}, 1fr)`,
    gap: vars.layout.gutter,
    paddingInline: vars.layout.margin,
  }),
]);
