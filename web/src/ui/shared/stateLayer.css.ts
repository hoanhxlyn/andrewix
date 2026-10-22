import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

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
