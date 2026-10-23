import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Group of tags, sized by its container. */
export const group = style(inComponents({ minWidth: 0 }));

/** Row of tags that scrolls sideways when they do not fit. */
export const list = style(
  inComponents({
    display: "flex",
    alignItems: "center",
    gap: vars.space.xs,
    overflowX: "auto",
    scrollbarWidth: "thin",
    // Room for the focus ring, which the scrolling row would otherwise clip.
    padding: vars.space.xs,
  }),
);

/** One tag, selectable and removable. */
export const tag = style([
  stateLayer,
  inComponents({
    ...text.label,
    display: "inline-flex",
    alignItems: "center",
    gap: vars.space.xs,
    flexShrink: 0,
    height: vars.size.controlSmall,
    paddingInlineStart: vars.space.md,
    paddingInlineEnd: vars.space.xs,
    borderRadius: vars.shape.full,
    border: `${vars.border.outline} solid ${vars.color.outline}`,
    color: vars.color.onSurfaceVariant,
    whiteSpace: "nowrap",
    cursor: "pointer",
    outline: "none",
    selectors: {
      // Filled in the primary colour: a container tint is too close to the header behind it.
      "&[data-selected]": {
        background: vars.color.primary,
        borderColor: vars.color.primary,
        color: vars.color.onPrimary,
      },
    },
  }),
]);

/** Button inside a tag that removes it. */
export const remove = style([
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
  `${remove} > svg`,
  inComponents({ width: vars.size.iconSmall, height: vars.size.iconSmall }),
);
