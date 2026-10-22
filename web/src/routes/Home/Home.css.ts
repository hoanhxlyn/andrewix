import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text } from "@/styles/tokens.css";

/** Banner at the top of the home page introducing the app. */
export const hero = style([
  sprinkles({
    display: "flex",
    flexDirection: "column",
    alignItems: "flex-start",
    gap: "lg",
    padding: "xl",
    background: "primaryContainer",
    color: "onPrimaryContainer",
  }),
  inComponents({ flexShrink: 0 }),
]);

/** Name of the app in the hero. */
export const heroTitle = style(inComponents({ ...text.headline, margin: 0 }));

/** One-line description of the app in the hero. */
export const heroTagline = style(inComponents({ ...text.body, margin: 0 }));
