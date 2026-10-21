import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents } from "../styles/layers.css";
import { vars } from "../styles/tokens.css";
import { stateLayer } from "./stateLayer.css";

/** Button that shows only an icon. */
export const button = style([
  stateLayer,
  inComponents({
    appearance: "none",
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    width: vars.size.control,
    height: vars.size.control,
    border: 0,
    borderRadius: vars.shape.full,
    background: "transparent",
    color: vars.color.onSurfaceVariant,
    cursor: "pointer",
  }),
]);

globalStyle(
  `${button} svg`,
  inComponents({ width: vars.size.icon, height: vars.size.icon }),
);
