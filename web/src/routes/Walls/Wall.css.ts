import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, text, vars } from "@/styles/tokens.css";

/**
 * Box of one wallpaper: a full-screen dialog on the surface on compact, a raised dialog of 80% of
 * the window beside it.
 */
export const modal = style(
  inComponents({
    width: "100vw",
    height: "100vh",
    background: vars.color.surface,
    "@media": {
      [breakpoints.medium]: {
        width: "80vw",
        height: "80vh",
        borderRadius: vars.shape.extraLarge,
        background: vars.color.surfaceContainerHigh,
      },
    },
  }),
);

/** Box holding the picture and the skeleton that stands in for it. */
export const frame = style(
  inComponents({
    display: "flex",
    flex: 1,
    minHeight: 0,
    position: "relative",
    padding: vars.space.md,
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

/**
 * Bar over the wallpaper: the close button leading, then its path and source, then the star. The
 * 56px header of a full-screen dialog on compact, the roomier padding of a dialog beside it.
 */
export const header = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    gap: "sm",
    color: "onSurface",
  }),
  inComponents({
    flexShrink: 0,
    minHeight: vars.size.controlLarge,
    paddingInline: vars.space.xs,
    "@media": {
      [breakpoints.medium]: { padding: vars.space.xl },
    },
  }),
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
