import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/**
 * Scrolling box of the wallpaper cards. The virtualizer places each card itself, and leaves a gap
 * around the edges that the hover shadow and the focus ring draw into.
 */
export const grid = style(
  inComponents({
    display: "block",
    flex: 1,
    minHeight: 0,
    overflowY: "auto",
    outline: "none",
  }),
);

/**
 * One wallpaper of the grid: its picture over the name and source, with its star over the corner.
 * Rises one elevation level on hover, as a Material filled card does.
 */
export const card = style([
  sprinkles({ borderRadius: "medium" }),
  inComponents({
    position: "relative",
    height: "100%",
    overflow: "hidden",
    background: vars.color.surfaceVariant,
    color: vars.color.onSurface,
    cursor: "pointer",
    outline: "none",
    transition: `box-shadow ${vars.motion.duration} ${vars.motion.easing}`,
    selectors: {
      "&[data-hovered]": { boxShadow: vars.elevation.level1 },
      "&[data-focus-visible]": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
      },
    },
    "@media": {
      "(prefers-reduced-motion: reduce)": { transition: "none" },
    },
  }),
]);

/** Top-right corner of a card, holding its favorite star over the picture. */
export const corner = style(
  inComponents({
    position: "absolute",
    top: vars.space.sm,
    right: vars.space.sm,
    zIndex: vars.layer.raised,
  }),
);

/** Box holding the picture and the skeleton that stands in for it. */
export const frame = style(
  inComponents({ display: "block", position: "relative" }),
);

/** Skeleton over the picture's box, which the aspect ratio keeps its size. */
export const placeholder = style(
  inComponents({ position: "absolute", inset: 0 }),
);

/** The picture, cropped to one shape so the cards stay even while loading. */
export const image = style(
  inComponents({
    display: "block",
    width: "100%",
    aspectRatio: "16 / 9",
    objectFit: "cover",
    background: vars.color.surface,
    opacity: 0,
    transition: `opacity ${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`,
    selectors: { "&[data-loaded]": { opacity: 1 } },
    "@media": {
      "(prefers-reduced-motion: reduce)": { transition: "none" },
    },
  }),
);

/** Name and source of one wallpaper, under its picture. */
export const caption = style([
  sprinkles({
    display: "flex",
    flexDirection: "column",
    alignItems: "flex-start",
    gap: "xs",
    padding: "sm",
  }),
  inComponents({ minWidth: 0 }),
]);

/** File name of the wallpaper, cut when the card is too narrow. */
export const name = style(
  inComponents({
    ...text.body,
    alignSelf: "stretch",
    minWidth: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
  }),
);

/** Row after the last card holding the indicator of the cards still to come. */
export const loader = style(
  inComponents({
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  }),
);
