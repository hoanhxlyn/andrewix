import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Panel showing the source of the selected file. */
export const pane = style([
  sprinkles({ display: "flex", flexDirection: "column" }),
  inComponents({
    minWidth: 0,
    minHeight: 0,
    background: vars.color.surface,
    color: vars.color.onSurface,
  }),
]);

/** Path of the shown file, above the source. */
export const header = style([
  sprinkles({ color: "onSurfaceVariant", padding: "md" }),
  inComponents({
    ...text.label,
    margin: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
    background: vars.color.surfaceVariant,
  }),
]);

/** Scrollable source block. */
export const code = style([
  sprinkles({ padding: "md" }),
  inComponents({
    margin: 0,
    flex: 1,
    minHeight: 0,
    overflow: "auto",
    fontFamily: vars.typeface.mono,
    fontSize: vars.type.body.size,
    lineHeight: vars.type.body.lineHeight,
  }),
]);

// Shiki stamps light-theme colors inline on each token span; the dark pair lives in
// --shiki-dark, so only an !important rule can switch it per theme.
globalStyle(`[data-theme="dark"] .${code} span`, {
  color: "var(--shiki-dark) !important",
});

/** Empty and error state inside the source block. */
export const message = style(
  inComponents({ color: vars.color.onSurfaceVariant }),
);
