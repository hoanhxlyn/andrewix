import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { breakpoints, vars } from "@/styles/tokens.css";

const line = `${vars.border.outline} solid ${vars.color.outline}`;

/** Page frame splitting the tree pane from the source pane. */
export const page = style([
  sprinkles({ display: "flex" }),
  inComponents({
    height: "100%",
    flexDirection: "column",
    "@media": { [breakpoints.medium]: { flexDirection: "row" } },
  }),
]);

/** Pannable tree pane, above the source on compact windows. */
export const tree = style(inComponents({ flex: 1, minWidth: 0, minHeight: 0 }));

/** Source of the selected file, below the tree on compact windows. */
export const peek = style(
  inComponents({
    flex: 1,
    minWidth: 0,
    minHeight: 0,
    borderTop: line,
    "@media": {
      [breakpoints.medium]: { borderTop: 0, borderLeft: line },
    },
  }),
);
