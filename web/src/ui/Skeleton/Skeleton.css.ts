import { keyframes, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

const pulse = keyframes({
  "0%, 100%": { opacity: 1 },
  "50%": { opacity: 0.4 },
});

/** Placeholder filling a pane while its content loads. */
export const skeleton = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    gap: vars.space.sm,
    flex: 1,
    minHeight: 0,
    overflow: "hidden",
    padding: vars.space.md,
    background: vars.color.surface,
    "@media": {
      "(prefers-reduced-motion: no-preference)": {
        animation: `${pulse} 1.2s ${vars.motion.easing} infinite`,
      },
    },
  }),
);

/** A single block standing in for an image; the caller sizes and places it. */
export const image = style(
  inComponents({
    padding: 0,
    gap: 0,
    background: vars.color.surfaceVariant,
    "@media": {
      "(prefers-reduced-motion: no-preference)": {
        animation: `${pulse} 1.2s ${vars.motion.easing} infinite`,
      },
    },
  }),
);

/** One placeholder line of the skeleton; widths vary by position to look like text. */
export const line = style(
  inComponents({
    flexShrink: 0,
    // Bar plus gap add up to one body line, so the skeleton has the height of the text.
    height: `calc(${vars.type.body.lineHeight} - ${vars.space.sm})`,
    borderRadius: vars.shape.small,
    background: vars.color.surfaceVariant,
    selectors: {
      "&:nth-child(4n+1)": { width: "60%" },
      "&:nth-child(4n+2)": { width: "85%" },
      "&:nth-child(4n+3)": { width: "40%" },
      "&:nth-child(4n)": { width: "70%" },
    },
  }),
);
