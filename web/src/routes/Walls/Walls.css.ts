import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";

/** Card holding the toolbar and the wallpapers. */
export const layout = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "md" }),
  inComponents({ height: "100%", minHeight: 0 }),
]);

/** Toolbar above the wallpapers: the search row, then the filter chips. */
export const toolbar = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "md" }),
  inComponents({ flexShrink: 0 }),
]);

/** Search box with the sort button and the layout switch, kept on one line at every width. */
export const actions = sprinkles({
  display: "flex",
  alignItems: "center",
  gap: "md",
});

/** Filter chips: favorites, then the sources, on one line whose source chips scroll sideways. */
export const filters = sprinkles({
  display: "flex",
  alignItems: "center",
  gap: "md",
});

/** The favorites chip, kept whole at the start of the filter row while the sources scroll. */
export const favorites = style(inComponents({ flexShrink: 0 }));

/** The search box, a comfortable width that narrows to leave room for the buttons beside it. */
export const search = style(inComponents({ flex: "0 1 16rem", minWidth: 0 }));

/** Grid or table switch, pushed to the end of the search row. */
export const layoutSwitch = style(inComponents({ marginInlineStart: "auto" }));
