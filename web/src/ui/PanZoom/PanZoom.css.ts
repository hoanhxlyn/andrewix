import { createVar, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";

/** Horizontal offset of the surface, with its unit. */
export const panX = createVar();

/** Vertical offset of the surface, with its unit. */
export const panY = createVar();

/** Scale factor of the surface, without a unit. */
export const scale = createVar();

/** Window onto a larger surface that is moved by dragging and scaled by zooming. */
export const viewport = style(
  inComponents({
    position: "relative",
    overflow: "hidden",
    display: "grid",
    placeContent: "safe center",
    cursor: "grab",
    touchAction: "none",
    userSelect: "none",
    selectors: { "&[data-dragging]": { cursor: "grabbing" } },
  }),
);

/** The surface that moves and scales inside the viewport. */
export const surface = style([
  sprinkles({ padding: "xl" }),
  inComponents({
    width: "max-content",
    transform: `translate(${panX}, ${panY}) scale(${scale})`,
    transformOrigin: "0 0",
  }),
]);
