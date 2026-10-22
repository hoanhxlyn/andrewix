import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Tree of the repository's files and folders. */
export const tree = style(inComponents({ margin: 0, padding: 0 }));

/** One row: indent, chevron, type icon and name. Composes the state feedback. */
export const item = style([
  stateLayer,
  inComponents({
    minHeight: vars.size.control,
    paddingBlock: 0,
    paddingInlineEnd: vars.space.sm,
    // Rows are flattened siblings; React Aria sets --tree-item-level on each one.
    paddingInlineStart: `calc((var(--tree-item-level) - 1) * ${vars.size.icon} + ${vars.space.sm})`,
    borderRadius: vars.shape.small,
    color: vars.color.onSurface,
    cursor: "pointer",
    selectors: {
      "&[data-selected]": {
        background: vars.color.primaryContainer,
        color: vars.color.onPrimaryContainer,
      },
    },
  }),
]);

/** Contents of a row: chevron, type icon and name, laid out in one line. */
export const row = style([
  sprinkles({ display: "flex", alignItems: "center", gap: "sm" }),
  inComponents({
    width: "100%",
    minWidth: 0,
    minHeight: vars.size.control,
    whiteSpace: "nowrap",
  }),
]);

/** Spacer where the chevron sits on folder rows, keeping file icons aligned. */
export const spacer = style(
  inComponents({ width: vars.size.icon, flexShrink: 0 }),
);

/** Chevron of a folder row, turned down while the folder is open. */
export const chevronOpen = style(
  inComponents({
    transform: "rotate(90deg)",
    transition: `transform ${vars.motion.duration} ${vars.motion.easing}`,
  }),
);

/** Note shown when the query matches no file. */
export const empty = style([
  sprinkles({ color: "onSurfaceVariant", padding: "md" }),
  inComponents(text.body),
]);

globalStyle(
  `${row} > svg`,
  inComponents({
    width: vars.size.icon,
    height: vars.size.icon,
    flexShrink: 0,
  }),
);
