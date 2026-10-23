import { createVar, fallbackVar, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, vars } from "@/styles/tokens.css";

/**
 * Height of the bar above the source: an icon button plus a small margin above and below. Fixed,
 * so the compact tree overlay can start right under the bar.
 */
const barHeight = `calc(${vars.size.control} + 2 * ${vars.space.sm})`;

/** Card holding the tree sidebar and the source pane. */
export const layout = style([
  sprinkles({ display: "flex", gap: "md" }),
  inComponents({
    position: "relative",
    height: "100%",
    flexDirection: "column",
    "@media": { [breakpoints.medium]: { flexDirection: "row" } },
  }),
  // Unlayered to beat the recipe's sprinkled radius; the card chrome only floats on desktop.
  {
    borderRadius: 0,
    "@media": { [breakpoints.medium]: { borderRadius: vars.shape.medium } },
  },
]);

/** Width of the tree sidebar beside the source, as last dragged. */
export const sidebarWidth = createVar();

/** Tree sidebar beside the source pane when it is shown; on compact it overlays the source. */
export const pane = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "sm" }),
  inComponents({
    minWidth: 0,
    minHeight: 0,
    // Inside the card's padding, starting under the source's bar so its tree toggle stays reachable.
    position: "absolute",
    inset: vars.space.lg,
    insetBlockStart: `calc(${vars.space.lg} + ${barHeight})`,
    zIndex: vars.layer.raised,
    paddingBlockStart: vars.space.sm,
    background: vars.color.surface,
    "@media": {
      [breakpoints.medium]: {
        flex: `0 0 ${fallbackVar(sidebarWidth, vars.size.sidebar)}`,
        position: "static",
        paddingBlockStart: 0,
      },
    },
  }),
]);

/** Scrollable list of files and folders. */
export const scroller = style(
  inComponents({ flex: 1, minHeight: 0, overflow: "auto" }),
);

/** Divider that resizes the tree sidebar beside the source; the compact overlay has none. */
export const splitter = style({
  display: "none",
  // Fills the gap between the panes instead of adding its own on each side.
  marginInline: `calc(-1 * ${vars.space.md})`,
  "@media": { [breakpoints.medium]: { display: "block" } },
});

/** Source pane: the open files as tabs over the selected one. */
export const peek = style(
  inComponents({
    flex: 1,
    minWidth: 0,
    minHeight: 0,
    background: vars.color.surface,
  }),
);

/** Bar above the source with the tree toggle, the open files and the view options. */
export const bar = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    gap: "md",
    color: "onSurfaceVariant",
  }),
  inComponents({
    flexShrink: 0,
    height: barHeight,
    paddingInline: vars.space.md,
    background: vars.color.surfaceVariant,
  }),
]);
