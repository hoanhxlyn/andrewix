import { style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Floating surface the menu opens in, next to its trigger. */
export const popover = style(
  inComponents({
    zIndex: vars.layer.overlay,
    // Material's narrowest menu, so short labels do not make a cramped list.
    minWidth: "112px",
    padding: vars.space.xs,
    borderRadius: vars.shape.extraSmall,
    background: vars.color.surface,
    boxShadow: vars.elevation.level2,
    outline: "none",
  }),
);

/** List of the menu's items. */
export const menu = style(
  inComponents({ display: "flex", flexDirection: "column", outline: "none" }),
);

/** One item of the menu; a picked item is in the primary colour. */
export const item = style([
  stateLayer,
  inComponents({
    ...text.label,
    display: "flex",
    alignItems: "center",
    gap: vars.space.sm,
    height: vars.size.control,
    paddingInline: vars.space.md,
    borderRadius: vars.shape.extraSmall,
    color: vars.color.onSurface,
    whiteSpace: "nowrap",
    cursor: "pointer",
    outline: "none",
    selectors: { "&[data-selected]": { color: vars.color.primary } },
  }),
]);

/** Column of the check mark, kept empty on items that are not picked so the labels line up. */
export const check = style(
  inComponents({
    display: "inline-flex",
    flexShrink: 0,
    width: vars.size.iconSmall,
    height: vars.size.iconSmall,
  }),
);
