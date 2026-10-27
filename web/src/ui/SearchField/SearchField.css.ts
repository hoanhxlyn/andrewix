import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Material search bar: a filled pill with a leading icon, the input and a clear button. */
export const field = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    gap: "md",
    borderRadius: "full",
    background: "surfaceContainerHigh",
  }),
  inComponents({
    height: vars.size.controlLarge,
    paddingInlineStart: vars.space.lg,
    // The clear button's own padding spaces its icon from the edge; its room is kept while it
    // is hidden, so the input does not change width as it comes and goes.
    paddingInlineEnd: vars.space.sm,
    selectors: {
      // The bar has no outline to recolour, so keyboard focus gets the usual ring around it.
      "&:has(input[data-focus-visible])": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
        outlineOffset: vars.border.focusRing,
      },
    },
  }),
]);

/** The text input itself; the row around it carries the decoration. */
export const input = style(
  inComponents({
    ...text.body,
    flex: 1,
    minWidth: 0,
    background: "transparent",
    border: "none",
    outline: "none",
    color: vars.color.onSurface,
    caretColor: vars.color.primary,
    "::placeholder": { color: vars.color.onSurfaceVariant, opacity: 1 },
    // The clear button beside the input replaces the browser's own one for type="search".
    "::-webkit-search-cancel-button": { appearance: "none" },
  }),
);

globalStyle(
  `${field} > button`,
  inComponents({
    "@media": {
      "(prefers-reduced-motion: no-preference)": {
        // Visibility flips at the end of a hide and the start of a show, so the button stays
        // visible for the whole fade.
        transitionProperty: "opacity, transform, visibility",
        transitionDuration: vars.motion.duration,
        transitionTimingFunction: vars.motion.easing,
      },
    },
  }),
);

// React Aria marks the field empty; hidden, the button also leaves the tab order and the
// accessibility tree.
globalStyle(
  `${field}[data-empty] > button`,
  inComponents({
    opacity: 0,
    transform: "scale(0.8)",
    visibility: "hidden",
  }),
);

globalStyle(
  `${field} > svg`,
  inComponents({
    width: vars.size.icon,
    height: vars.size.icon,
    color: vars.color.onSurface,
  }),
);
