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
    paddingInline: vars.space.md,
    borderRadius: vars.shape.small,
    border: `${vars.border.outline} solid ${vars.color.outline}`,
    color: vars.color.onSurfaceVariant,
    whiteSpace: "nowrap",
    cursor: "pointer",
    outline: "none",
    selectors: {
      // A Material filter chip: the selected one is filled and loses its outline.
      "&[data-selected]": {
        background: vars.color.secondaryContainer,
        borderColor: vars.color.secondaryContainer,
        color: vars.color.onSecondaryContainer,
      },
    },
  }),
]);

globalStyle(
  `${tag} > svg`,
  inComponents({ width: vars.size.iconChip, height: vars.size.iconChip }),
);

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
