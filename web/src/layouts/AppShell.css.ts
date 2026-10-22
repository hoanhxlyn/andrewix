import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, text, vars } from "@/styles/tokens.css";

/** Page frame holding the app bar and the content. */
export const shell = style([
  sprinkles({ display: "flex", flexDirection: "column" }),
  inComponents({ height: "100%" }),
]);

/** Top bar of the app. */
export const appBar = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    gap: "lg",
    background: "surface",
    boxShadow: "level1",
  }),
  inComponents({
    padding: `${vars.space.sm} ${vars.space.md}`,
    zIndex: vars.layer.raised,
    "@media": {
      [breakpoints.medium]: { padding: `${vars.space.md} ${vars.space.xl}` },
    },
  }),
]);

/** App title in the top bar. */
export const title = style([
  sprinkles({ color: "onSurface" }),
  inComponents({ ...text.title, textDecoration: "none" }),
]);

/** Main content area below the top bar. */
export const main = style(
  inComponents({ flex: 1, minHeight: 0, overflow: "auto" }),
);
