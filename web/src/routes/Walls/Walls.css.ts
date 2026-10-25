import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, text, vars } from "@/styles/tokens.css";

/** Card holding the search bar and the wallpaper grid. */
export const layout = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "md" }),
  inComponents({ height: "100%", minHeight: 0 }),
]);

/** Search bar and the source chips, above the wallpapers. */
export const toolbar = style([
  sprinkles({ display: "flex", alignItems: "center", gap: "md" }),
  inComponents({ flexShrink: 0, flexWrap: "wrap" }),
]);

/** The search box, a fixed comfortable width; the chips take the rest of the row. */
export const search = style(
  inComponents({ flex: "0 0 16rem", maxWidth: "100%" }),
);

/** Grid of wallpaper cards, fixed columns per window class. */
export const grid = style([
  sprinkles({ display: "grid", gap: "md" }),
  inComponents({
    flex: 1,
    minHeight: 0,
    overflowY: "auto",
    gridTemplateColumns: "repeat(1, 1fr)",
    gridAutoRows: "min-content",
    // Room for the hover shadow and the focus ring, which the scroll container would clip at the
    // edges of a row otherwise.
    padding: vars.space.sm,
    "@media": {
      [breakpoints.medium]: { gridTemplateColumns: "repeat(3, 1fr)" },
      [breakpoints.expanded]: { gridTemplateColumns: "repeat(6, 1fr)" },
    },
  }),
]);

/** One wallpaper: its picture over the name and source. */
export const item = style([
  sprinkles({ borderRadius: "medium" }),
  inComponents({
    display: "block",
    overflow: "hidden",
    background: vars.color.surfaceVariant,
    textDecoration: "none",
    color: vars.color.onSurface,
    // Off-screen cards are skipped by layout and paint; the images are lazy anyway.
    contentVisibility: "auto",
    // Tall enough for a card of the single mobile column, so the scrollbar does not jump.
    containIntrinsicSize: "auto 260px",
    transition: `transform ${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}, box-shadow ${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`,
    selectors: {
      "&:hover": {
        boxShadow: vars.elevation.level2,
        transform: "scale(1.03)",
      },
      "&:focus-visible": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
      },
    },
    "@media": {
      "(prefers-reduced-motion: reduce)": {
        transition: "none",
        selectors: { "&:hover": { transform: "none" } },
      },
    },
  }),
]);

/** Box holding the picture and the skeleton that stands in for it. */
export const frame = style(
  inComponents({ display: "block", position: "relative" }),
);

/** Skeleton over the picture's box, which the aspect ratio keeps its size. */
export const placeholder = style(
  inComponents({ position: "absolute", inset: 0 }),
);

/** The picture, cropped to one shape so the grid stays even while loading. */
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
    flex: 1,
    alignSelf: "stretch",
    minWidth: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
  }),
);
