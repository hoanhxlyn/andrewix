import { createVar, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

/** Horizontal distance between a node and its children, filled by the connector lines. */
const connector = createVar();

const line = `${vars.border.outline} solid ${vars.color.outline}`;

/** Top-level list of the tree. Holds the connector size for every branch below it. */
export const tree = style(
  inComponents({
    vars: { [connector]: vars.space.xl },
    margin: 0,
    padding: 0,
    listStyle: "none",
    whiteSpace: "nowrap",
  }),
);

/** Children of a folder, stacked and joined to it by connector lines. */
export const list = style(
  inComponents({
    position: "relative",
    margin: 0,
    paddingBlock: 0,
    paddingInlineEnd: 0,
    paddingInlineStart: connector,
    listStyle: "none",
    selectors: {
      "&::before": {
        content: '""',
        position: "absolute",
        left: 0,
        top: "50%",
        width: `calc(${connector} / 2)`,
        borderTop: line,
      },
    },
  }),
);

/** One file or folder, in a row with its children. */
export const item = style(
  inComponents({
    position: "relative",
    display: "flex",
    alignItems: "center",
    paddingBlock: vars.space.xs,
    selectors: {
      [`${list} > &::before`]: {
        content: '""',
        position: "absolute",
        left: `calc(${connector} / -2)`,
        top: 0,
        bottom: 0,
        borderLeft: line,
      },
      [`${list} > &:first-child::before`]: { top: "50%" },
      [`${list} > &:last-child::before`]: { bottom: "50%" },
      [`${list} > &::after`]: {
        content: '""',
        position: "absolute",
        left: `calc(${connector} / -2)`,
        top: "50%",
        width: `calc(${connector} / 2)`,
        borderTop: line,
      },
    },
  }),
);
