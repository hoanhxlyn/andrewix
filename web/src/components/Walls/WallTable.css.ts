import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { gallery, vars } from "@/styles/tokens.css";

/** Scrolling table of the wallpapers, filling the card under the toolbar. */
export const table = style(inComponents({ flex: 1, minHeight: 0 }));

/** Contents of the favorite column, heading and cell alike. */
export const center = style(inComponents({ justifyContent: "center" }));

/** Box of a row's thumbnail and the skeleton that stands in for it. */
export const thumb = style([
  sprinkles({ borderRadius: "small" }),
  inComponents({
    position: "relative",
    flexShrink: 0,
    height: `${gallery.thumbHeight}px`,
    aspectRatio: "16 / 9",
    overflow: "hidden",
    background: vars.color.surfaceVariant,
  }),
]);

/** Skeleton over the thumbnail's box while the picture is on its way. */
export const placeholder = style(
  inComponents({ position: "absolute", inset: 0 }),
);

/** The thumbnail, cropped to the box. */
export const image = style(
  inComponents({
    display: "block",
    width: "100%",
    height: "100%",
    objectFit: "cover",
    opacity: 0,
    transition: `opacity ${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`,
    selectors: { "&[data-loaded]": { opacity: 1 } },
    "@media": {
      "(prefers-reduced-motion: reduce)": { transition: "none" },
    },
  }),
);

/** File name of the wallpaper, cut when the column is too narrow. */
export const name = style(
  inComponents({
    minWidth: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
  }),
);
