import { globalStyle, keyframes, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, text, vars } from "@/styles/tokens.css";

/** The dialog growing into place as it opens. */
const fadeIn = keyframes({
  from: { opacity: 0, transform: "scale(0.96)" },
  to: { opacity: 1, transform: "scale(1)" },
});

/** The reverse, played while the route is still mounted before it navigates away. */
const fadeOut = keyframes({
  from: { opacity: 1, transform: "scale(1)" },
  to: { opacity: 0, transform: "scale(0.96)" },
});

const backdropIn = keyframes({ from: { opacity: 0 }, to: { opacity: 1 } });
const backdropOut = keyframes({ from: { opacity: 1 }, to: { opacity: 0 } });

const timing = `${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`;

/** Dialog of one wallpaper: fullscreen on compact, 80% of the window beside it. */
export const dialog = style(
  inComponents({
    width: "100vw",
    height: "100vh",
    maxWidth: "none",
    maxHeight: "none",
    margin: "auto",
    padding: 0,
    border: "none",
    borderRadius: 0,
    overflow: "hidden",
    background: vars.color.surfaceVariant,
    boxShadow: vars.elevation.level2,
    selectors: {
      "&[open]": {
        animation: `${fadeIn} ${timing}`,
        "@media": {
          "(prefers-reduced-motion: reduce)": { animation: "none" },
        },
      },
      "&[data-closing]": {
        animation: `${fadeOut} ${timing} forwards`,
        "@media": {
          "(prefers-reduced-motion: reduce)": { animation: "none" },
        },
      },
      "&[data-closing]::backdrop": {
        animation: `${backdropOut} ${timing} forwards`,
        "@media": {
          "(prefers-reduced-motion: reduce)": { animation: "none" },
        },
      },
    },
    "@media": {
      [breakpoints.medium]: {
        width: "80vw",
        height: "80vh",
        borderRadius: vars.shape.extraLarge,
      },
    },
  }),
);

// Only laid out while open, so the closed dialog in the document stays unseen.
globalStyle(
  `${dialog}[open]`,
  inComponents({ display: "flex", flexDirection: "column" }),
);

/** The page behind the dialog, dimmed by the scrim and blurred over it. */
globalStyle(`${dialog}[open]::backdrop`, {
  background: "rgb(0 0 0 / 0.32)",
  backdropFilter: "blur(8px)",
  animation: `${backdropIn} ${timing}`,
  "@media": {
    "(prefers-reduced-motion: reduce)": { animation: "none" },
  },
});

/** Box holding the picture and the skeleton that stands in for it. */
export const frame = style(
  inComponents({
    display: "flex",
    flex: 1,
    minHeight: 0,
    position: "relative",
  }),
);

/** Skeleton over the picture's box while the picture is on its way. */
export const placeholder = style(
  inComponents({ position: "absolute", inset: 0 }),
);

/** The wallpaper, whole and letterboxed rather than cropped. */
export const image = style(
  inComponents({
    flex: 1,
    width: "100%",
    minHeight: 0,
    objectFit: "contain",
    opacity: 0,
    transition: `opacity ${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`,
    selectors: { "&[data-loaded]": { opacity: 1 } },
    "@media": {
      "(prefers-reduced-motion: reduce)": { transition: "none" },
    },
  }),
);

/** Bar over the wallpaper with its path, its source and the close button. */
export const header = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    gap: "sm",
    padding: "xl",
    color: "onSurface",
  }),
  inComponents({ flexShrink: 0 }),
]);

/** Path of the wallpaper, cut when the dialog is narrow. */
export const name = style(
  inComponents({
    ...text.body,
    flex: 1,
    minWidth: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
    color: vars.color.onSurfaceVariant,
  }),
);
