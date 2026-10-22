import {
  type GlobalStyleRule,
  layer,
  type StyleRule,
  style,
} from "@vanilla-extract/css";
import { vars } from "./tokens.css";

// Cascade order, lowest to highest: element defaults, component styles, then utilities, so a
// sprinkle always beats a component rule no matter which file is emitted first.
export const base = layer("base");
export const components = layer("components");
export const utilities = layer("utilities");

export const inBase = (rule: GlobalStyleRule) => ({
  "@layer": { [base]: rule },
});

export const inComponents = (rule: StyleRule) => ({
  "@layer": { [components]: rule },
});

/**
 * Hover, focus and pressed feedback for interactive elements. Compose it into the element.
 * The states are the `data-*` attributes React Aria sets, which ignore touch hover and mouse focus.
 */
export const stateLayer = style(
  inComponents({
    position: "relative",
    "::before": {
      content: '""',
      position: "absolute",
      inset: 0,
      borderRadius: "inherit",
      background: "currentColor",
      opacity: 0,
      pointerEvents: "none",
      transition: `opacity ${vars.motion.duration} ${vars.motion.easing}`,
    },
    selectors: {
      "&[data-hovered]::before": { opacity: vars.state.hover },
      "&[data-focus-visible]::before": { opacity: vars.state.focus },
      "&[data-pressed]::before": { opacity: vars.state.pressed },
      "&[data-disabled]::before": { opacity: 0 },
      "&[data-focus-visible]": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
        outlineOffset: vars.border.focusRing,
      },
    },
  }),
);
