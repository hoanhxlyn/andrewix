import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Tree of the repository's files and folders. */
export const tree = style(inComponents({ margin: 0, padding: 0 }));

/** Focusable row element React Aria renders; its default browser outline is replaced by the ring on the row contents. */
export const item = style(inComponents({ outline: "none" }));

/** Contents of a row: indent, chevron, type icon and name. Composes the state feedback. */
export const row = style([
  stateLayer,
  sprinkles({ display: "flex", alignItems: "center", gap: "sm" }),
  inComponents({
    width: "100%",
    minWidth: 0,
    minHeight: vars.size.control,
    paddingBlock: 0,
    paddingInlineEnd: vars.space.sm,
    // Rows are flattened siblings; React Aria sets --tree-item-level on each one.
    paddingInlineStart: `calc((var(--tree-item-level) - 1) * ${vars.size.icon} + ${vars.space.sm})`,
    borderRadius: vars.shape.small,
    color: vars.color.onSurface,
    cursor: "pointer",
    whiteSpace: "nowrap",
    // Indent guides: one line per ancestor level, under the centre of that ancestor's chevron.
    // A pseudo-element, since `::before` is the state layer and the selected background would
    // replace a background image on the row itself.
    "::after": {
      content: '""',
      position: "absolute",
      insetBlock: 0,
      insetInlineStart: `calc(${vars.space.sm} + ${vars.size.control} / 2)`,
      width: `calc((var(--tree-item-level) - 1) * ${vars.size.icon})`,
      // One tile per level, each starting with the line.
      backgroundImage: `linear-gradient(to right, ${vars.color.outline} ${vars.border.outline}, transparent ${vars.border.outline})`,
      backgroundSize: `${vars.size.icon} 100%`,
      backgroundRepeat: "repeat-x",
      pointerEvents: "none",
    },
    selectors: {
      "&[data-selected]": {
        background: vars.color.primaryContainer,
        color: vars.color.onPrimaryContainer,
      },
      // Inside the row: an outside ring is clipped by the scroller and the neighbouring rows.
      "&[data-focus-visible]": {
        outlineOffset: `calc(-1 * ${vars.border.focusRing})`,
      },
    },
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
