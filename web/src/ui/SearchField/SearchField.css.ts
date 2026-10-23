import { globalStyle, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Search row with a leading icon, the input and a clear button. */
export const field = style([
  sprinkles({
    display: "flex",
    alignItems: "center",
    gap: "sm",
    borderRadius: "full",
    background: "surface",
  }),
  inComponents({
    paddingInline: vars.space.sm,
    border: `${vars.border.outline} solid ${vars.color.outline}`,
    selectors: {
      "&:focus-within": { borderColor: vars.color.primary },
    },
  }),
]);

/** The text input itself; the row around it carries the decoration. */
export const input = style(
  inComponents({
    ...text.body,
    flex: 1,
    minWidth: 0,
    background: "transparent",
    border: "none",
    outline: "none",
    color: vars.color.onSurface,
    // The clear button beside the input replaces the browser's own one for type="search".
    "::-webkit-search-cancel-button": { appearance: "none" },
  }),
);

globalStyle(
  `${field} > svg`,
  inComponents({
    width: vars.size.icon,
    height: vars.size.icon,
  }),
);

// The generic icon button is sized for toolbars; the clear button stays compact inside the pill.
globalStyle(
  `${field} > button`,
  inComponents({
    width: vars.size.controlSmall,
    height: vars.size.controlSmall,
  }),
);

globalStyle(
  `${field} > button > svg`,
  inComponents({
    width: vars.size.iconSmall,
    height: vars.size.iconSmall,
  }),
);
