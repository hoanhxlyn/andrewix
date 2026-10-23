import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text } from "@/styles/tokens.css";

/** Message filling the space of content that is missing or cannot be shown. */
export const empty = style([
  sprinkles({ padding: "md", color: "onSurfaceVariant" }),
  inComponents({ ...text.body, flex: 1, minHeight: 0, margin: 0 }),
]);
