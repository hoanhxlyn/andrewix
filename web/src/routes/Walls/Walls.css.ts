import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { vars } from "@/styles/tokens.css";

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

/** Row of the toolbar holding the search box, the sort button and the layout switch. */
export const actions = sprinkles({
  display: "flex",
  alignItems: "center",
  gap: "md",
});

/** Row of the toolbar holding the filter chips: favorites, then the sources. */
export const filters = sprinkles({
  display: "flex",
  alignItems: "center",
  gap: "md",
});

/** The favorites chip, which stays in reach while the source chips scroll. */
export const favorites = style(inComponents({ flexShrink: 0 }));

/** The search box of the wallpapers, sharing its row with the buttons. */
export const search = style(
  inComponents({ flex: `0 1 ${vars.size.search}`, minWidth: 0 }),
);

/** The switch between the grid and the table of wallpapers. */
export const layoutSwitch = style(inComponents({ marginInlineStart: "auto" }));
