import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, vars } from "@/styles/tokens.css";

/** Card holding the tree sidebar and the source pane. */
export const layout = style([
  sprinkles({ display: "flex", gap: "md" }),
  inComponents({
    position: "relative",
    height: "100%",
    flexDirection: "column",
    borderRadius: 0,
    "@media": {
      [breakpoints.medium]: {
        flexDirection: "row",
        borderRadius: vars.shape.medium,
      },
    },
  }),
]);

/** Tree sidebar beside the source pane when it is shown; on compact it overlays the source. */
export const pane = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "sm" }),
  inComponents({
    minWidth: 0,
    minHeight: 0,
    position: "absolute",
    inset: 0,
    zIndex: vars.layer.raised,
    background: vars.color.surface,
    boxShadow: vars.elevation.level2,
    "@media": {
      [breakpoints.medium]: {
        flex: `0 0 ${vars.size.sidebar}`,
        position: "static",
        boxShadow: "none",
      },
    },
  }),
]);

/** Collapsed sidebar: just the toggle, pinned to the top of the source pane. */
export const rail = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    justifyContent: "flex-start",
    gap: "sm",
  }),
  inComponents({
    width: "100%",
    height: vars.size.control,
    alignSelf: "flex-start",
    "@media": {
      [breakpoints.medium]: { width: vars.size.control, height: "auto" },
    },
  }),
]);

/** Row holding the sidebar toggle and the search field. */
export const bar = style([
  sprinkles({ display: "flex", alignItems: "center", gap: "sm" }),
  inComponents({ minWidth: 0 }),
]);

/** Search field taking the rest of the toggle row. */
export const search = style(inComponents({ flex: 1, minWidth: 0 }));

/** Scrollable list of files and folders. */
export const scroller = style(
  inComponents({ flex: 1, minHeight: 0, overflow: "auto" }),
);

/** Source pane of the selected file, divided from the tree sidebar. */
export const peek = style(
  inComponents({
    flex: 1,
    minWidth: 0,
    minHeight: 0,
    borderTop: `${vars.border.outline} solid ${vars.color.outline}`,
    "@media": {
      [breakpoints.medium]: {
        border: "none",
        borderLeft: `${vars.border.outline} solid ${vars.color.outline}`,
      },
    },
  }),
);
