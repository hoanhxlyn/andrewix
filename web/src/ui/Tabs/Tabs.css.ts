import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Tabs with their panel stacked under them. */
export const tabs = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    minWidth: 0,
    minHeight: 0,
  }),
);

/** Row of tabs, as tall as its bar, that scrolls sideways when they do not fit. */
export const list = style(
  inComponents({
    display: "flex",
    alignSelf: "stretch",
    flex: 1,
    minWidth: 0,
    overflowX: "auto",
    scrollbarWidth: "thin",
  }),
);

/** One tab, selectable and closable. */
export const tab = style([
  stateLayer,
  inComponents({
    ...text.label,
    display: "inline-flex",
    alignItems: "center",
    gap: vars.space.xs,
    flexShrink: 0,
    paddingInlineStart: vars.space.md,
    paddingInlineEnd: vars.space.xs,
    // Transparent until selected, so selecting a tab does not shift its label.
    borderBlockStart: `${vars.border.indicator} solid transparent`,
    color: vars.color.onSurfaceVariant,
    whiteSpace: "nowrap",
    cursor: "pointer",
    outline: "none",
    selectors: {
      // The selected tab takes the panel's surface and joins the content under it.
      "&[data-selected]": {
        background: vars.color.surface,
        borderBlockStartColor: vars.color.primary,
        color: vars.color.onSurface,
      },
      // Inset, since the scrolling row clips a ring drawn outside the tab.
      "&[data-focus-visible]": {
        outlineOffset: `calc(-1 * ${vars.border.focusRing})`,
      },
    },
  }),
]);

/** Button inside a tab that closes it. */
export const close = style([
  stateLayer,
  inComponents({
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    width: vars.size.icon,
    height: vars.size.icon,
    padding: 0,
    border: "none",
    borderRadius: vars.shape.full,
    appearance: "none",
    background: "transparent",
    color: "inherit",
    cursor: "pointer",
  }),
]);

globalStyle(
  `${close} > svg`,
  inComponents({ width: vars.size.iconSmall, height: vars.size.iconSmall }),
);

/** Content of the selected tab, filling the space under the tabs. */
export const panel = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    flex: 1,
    minHeight: 0,
    outline: "none",
    selectors: {
      "&[data-focus-visible]": {
        outline: `${vars.border.focusRing} solid ${vars.color.primary}`,
        outlineOffset: `calc(-1 * ${vars.border.focusRing})`,
      },
    },
  }),
);
