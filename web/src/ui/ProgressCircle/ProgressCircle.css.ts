import { keyframes, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

const turn = keyframes({ to: { transform: "rotate(360deg)" } });

// Lengths are in hundredths of the circle (the arc's `pathLength`). The arc grows from a dot to
// three quarters of the circle, the 270 degrees of M3, then shrinks by moving its tail forward.
const arcLength = keyframes({
  "0%": { strokeDasharray: "1 200", strokeDashoffset: "0" },
  "50%": { strokeDasharray: "75 200", strokeDashoffset: "-25" },
  "100%": { strokeDasharray: "75 200", strokeDashoffset: "-99" },
});

/** Box of the progress indicator, sized for the circle. */
export const root = style(
  inComponents({
    display: "inline-flex",
    flexShrink: 0,
    width: vars.size.progress,
    height: vars.size.progress,
    color: vars.color.primary,
  }),
);

/** The circle's drawing, turning while work goes on unless the user asks for less motion. */
export const svg = style(
  inComponents({
    width: "100%",
    height: "100%",
    "@media": {
      "(prefers-reduced-motion: no-preference)": {
        animation: `${turn} ${vars.motion.progressTurn} linear infinite`,
      },
    },
  }),
);

/** The arc that grows and shrinks as the circle turns. */
export const arc = style(
  inComponents({
    fill: "none",
    stroke: "currentColor",
    strokeDasharray: "75 200",
    "@media": {
      "(prefers-reduced-motion: no-preference)": {
        animation: `${arcLength} ${vars.motion.progressArc} ${vars.motion.progressEasing} infinite`,
      },
    },
  }),
);
