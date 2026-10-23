import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

/** Draggable divider between two panes: a thin line inside a wider area to grab. */
export const splitter = style(
  inComponents({
    position: "relative",
    flexShrink: 0,
    width: vars.space.md,
    borderRadius: vars.shape.small,
    cursor: "col-resize",
    // Touch drags move the divider instead of scrolling the page.
    touchAction: "none",
    outline: "none",
    "::after": {
      content: '""',
      position: "absolute",
      insetBlock: 0,
      insetInlineStart: "50%",
      width: vars.border.outline,
      transform: "translateX(-50%)",
      background: vars.color.outline,
      transition: `background ${vars.motion.duration} ${vars.motion.easing}`,
    },
    selectors: {
      "&[data-hovered]::after, &[data-dragging]::after, &[data-focus-visible]::after":
        {
          width: vars.border.indicator,
          background: vars.color.primary,
        },
      "&[data-focus-visible]": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
        outlineOffset: `calc(-1 * ${vars.border.focusRing})`,
      },
    },
  }),
);
