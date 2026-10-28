import { keyframes, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

const rise = keyframes({
  from: { opacity: 0, transform: "translateY(100%)" },
  to: { opacity: 1, transform: "none" },
});

/** Column of toasts, centred over the bottom of the page as Material places a snackbar. */
export const region = style([
  sprinkles({
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    gap: "sm",
    padding: "lg",
  }),
  inComponents({
    position: "fixed",
    insetBlockEnd: 0,
    insetInline: 0,
    zIndex: vars.layer.overlay,
    // Only the toasts take presses; the column around them lets clicks through to the page.
    pointerEvents: "none",
  }),
]);

/**
 * One toast: a raised surface of the page's own color, so it reads as part of the theme. One line
 * is 48dp tall, two lines grow past it; it takes the width of its text up to 672dp.
 */
export const toast = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    gap: "sm",
    borderRadius: "extraSmall",
    background: "surfaceContainerHigh",
    color: "onSurface",
    boxShadow: "level3",
  }),
  inComponents({
    pointerEvents: "auto",
    width: "fit-content",
    maxWidth: "min(100%, 672px)",
    minHeight: vars.size.touchTarget,
    paddingBlock: vars.space.xs,
    paddingInline: vars.space.lg,
    animation: `${rise} ${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`,
    "@media": { "(prefers-reduced-motion: reduce)": { animation: "none" } },
  }),
]);

/** The text of a toast, which takes the room the close button leaves. */
export const content = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    gap: vars.space.xs,
    flex: 1,
    minWidth: 0,
  }),
);

/** First line of a toast, saying what happened. */
export const title = style(inComponents({ ...text.label }));

/** Detail under the title, saying what it amounted to, at the body weight of snackbar text. */
export const description = style(
  inComponents({
    ...text.label,
    fontWeight: vars.type.body.weight,
    color: vars.color.onSurfaceVariant,
  }),
);
