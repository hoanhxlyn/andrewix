import {
  createVar,
  fallbackVar,
  globalStyle,
  style,
} from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { border, breakpoints, text, vars } from "@/styles/tokens.css";

/**
 * Height of the bar above the source: an icon button plus a small margin above and below. Fixed,
 * so the compact tree overlay can start right under the bar.
 */
const barHeight = `calc(${vars.size.control} + 2 * ${vars.space.sm})`;

/** Page surface holding the tree sidebar and the source pane, filling the area under the app bar. */
export const layout = style([
  sprinkles({
    display: "flex",
    gap: "md",
    padding: "lg",
    background: "surface",
    color: "onSurface",
  }),
  inComponents({
    ...text.body,
    position: "relative",
    height: "100%",
    flexDirection: "column",
    "@media": { [breakpoints.medium]: { flexDirection: "row" } },
  }),
]);

/** Width of the tree sidebar beside the source, as last dragged. */
export const sidebarWidth = createVar();

/** Tree sidebar beside the source pane when it is shown; on compact it overlays the source. */
export const pane = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "sm" }),
  inComponents({
    minWidth: 0,
    minHeight: 0,
    // Inside the page's padding, starting under the source's bar so its tree toggle stays reachable.
    position: "absolute",
    inset: vars.space.lg,
    insetBlockStart: `calc(${vars.space.lg} + ${barHeight})`,
    zIndex: vars.layer.raised,
    paddingBlockStart: vars.space.sm,
    background: vars.color.surface,
    // Clipped while the sidebar narrows, keeping room for the search field's focus ring: its
    // width plus its offset from the field.
    overflow: "clip",
    overflowClipMargin: `${2 * Number.parseInt(border.focusRing, 10)}px`,
    "@media": {
      [breakpoints.medium]: {
        flex: `0 0 ${fallbackVar(sidebarWidth, vars.size.sidebar)}`,
        position: "static",
        paddingBlockStart: 0,
      },
      "(prefers-reduced-motion: no-preference)": {
        // Visibility flips at the end of a hide and the start of a show, so the pane stays
        // visible for the whole slide.
        transitionProperty:
          "flex-basis, margin-inline-end, opacity, visibility",
        transitionDuration: vars.motion.duration,
        transitionTimingFunction: vars.motion.easing,
      },
    },
    selectors: {
      // A dragged width follows the pointer instead of easing after it.
      [`${layout}:has(> [data-dragging]) &`]: { transition: "none" },
    },
  }),
]);

/** Tree sidebar while it is hidden: kept mounted so it can slide out and back in. */
export const paneHidden = style(
  inComponents({
    opacity: 0,
    visibility: "hidden",
    "@media": {
      [breakpoints.medium]: {
        flexBasis: 0,
        // Also takes back the layout gap after it, so the source fills the page.
        marginInlineEnd: `calc(-1 * ${vars.space.md})`,
      },
    },
  }),
);

/** Fixed width of the sidebar's contents, so they are clipped rather than squeezed as it narrows. */
globalStyle(
  `${pane} > *`,
  inComponents({
    "@media": {
      [breakpoints.medium]: {
        minWidth: fallbackVar(sidebarWidth, vars.size.sidebar),
      },
    },
  }),
);

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

/** Bar above the open files with the tree toggle, the shown file and the view options. */
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

/** Path of the shown file in the bar. */
export const title = style(
  inComponents({
    ...text.label,
    flex: 1,
    minWidth: 0,
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
    color: vars.color.onSurface,
  }),
);

/** Row of the open files, between the bar and the source. */
export const tabRow = style(
  inComponents({
    display: "flex",
    flexShrink: 0,
    height: vars.size.control,
    background: vars.color.surfaceVariant,
    borderBlockStart: `${vars.border.outline} solid ${vars.color.outline}`,
  }),
);
