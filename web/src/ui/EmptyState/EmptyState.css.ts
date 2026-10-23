import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Icon and message filling the space of content that is missing or cannot be shown. */
export const empty = style([
  sprinkles({
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    gap: "md",
    padding: "md",
    color: "onSurfaceVariant",
  }),
  inComponents({ ...text.body, flex: 1, minHeight: 0, textAlign: "center" }),
]);

globalStyle(
  `${empty} > svg`,
  inComponents({ width: vars.size.iconLarge, height: vars.size.iconLarge }),
);

/** Message under the icon. */
export const message = style(inComponents({ margin: 0 }));
