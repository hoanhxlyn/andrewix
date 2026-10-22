import { style } from "@vanilla-extract/css";
import { inComponents } from "../../styles/layers.css";
import { vars } from "../../styles/tokens.css";

/** Hover, focus and pressed feedback for interactive elements. Compose it into the element. */
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
      "&:hover::before": { opacity: vars.state.hover },
      "&:focus-visible::before": { opacity: vars.state.focus },
      "&:active::before": { opacity: vars.state.pressed },
      "&:disabled::before": { opacity: 0 },
      "&:focus-visible": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
        outlineOffset: vars.border.focusRing,
      },
    },
  }),
);
