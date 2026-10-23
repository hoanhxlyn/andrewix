import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, vars } from "@/styles/tokens.css";
import { headerHeight } from "@/ui/CodePeek/CodePeek.css";

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

/** Tree sidebar beside the source pane when it is shown; on compact it overlays the source. */
export const pane = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "sm" }),
  inComponents({
    minWidth: 0,
    minHeight: 0,
    // Inside the card's padding, starting under the source's bar so its tree toggle stays reachable.
    position: "absolute",
    inset: vars.space.lg,
    insetBlockStart: `calc(${vars.space.lg} + ${headerHeight})`,
    zIndex: vars.layer.raised,
    paddingBlockStart: vars.space.sm,
    background: vars.color.surface,
    "@media": {
      [breakpoints.medium]: {
        flex: `0 0 ${vars.size.sidebar}`,
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

/** Source pane of the selected file, divided from the tree sidebar while that is shown. */
export const peek = style(
  inComponents({
    flex: 1,
    minWidth: 0,
    minHeight: 0,
    "@media": {
      [breakpoints.medium]: {
        selectors: {
          [`${pane} ~ &`]: {
            borderLeft: `${vars.border.outline} solid ${vars.color.outline}`,
          },
        },
      },
    },
  }),
);
