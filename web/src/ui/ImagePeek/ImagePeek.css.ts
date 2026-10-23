import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { vars } from "@/styles/tokens.css";

/** Scrollable area holding the shown image. */
export const frame = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    padding: "md",
  }),
  inComponents({
    flex: 1,
    minHeight: 0,
    overflow: "auto",
    background: vars.color.surface,
  }),
]);

/** The image, scaled down to fit the pane but never up past its own size. */
export const image = style(
  inComponents({
    maxWidth: "100%",
    maxHeight: "100%",
    objectFit: "contain",
  }),
);
