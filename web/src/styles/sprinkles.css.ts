import { createSprinkles, defineProperties } from "@vanilla-extract/sprinkles";
import { utilities } from "./layers.css";
import { breakpoints, vars } from "./tokens.css";

// Layout utilities. Mobile-first: unconditional values apply from the compact window class up.
const layoutProperties = defineProperties({
  "@layer": utilities,
  conditions: {
    compact: {},
    medium: { "@media": breakpoints.medium },
    expanded: { "@media": breakpoints.expanded },
  },
  defaultCondition: "compact",
  properties: {
    display: ["none", "block", "flex", "inline-flex", "grid"],
    flexDirection: ["row", "column"],
    flexWrap: ["nowrap", "wrap"],
    alignItems: ["stretch", "flex-start", "center", "flex-end"],
    justifyContent: ["flex-start", "center", "flex-end", "space-between"],
    gap: vars.space,
    padding: vars.space,
  },
});

// Theme-aware properties. Values are CSS variables, so light and dark need no conditions.
const themeProperties = defineProperties({
  "@layer": utilities,
  properties: {
    color: vars.color,
    background: vars.color,
    borderRadius: vars.shape,
    boxShadow: vars.elevation,
    // Border variants: each sets width, style and color together.
    border: {
      outline: {
        borderWidth: vars.border.outline,
        borderStyle: "solid",
        borderColor: vars.color.outline,
      },
      focus: {
        borderWidth: vars.border.focusRing,
        borderStyle: "solid",
        borderColor: vars.color.primary,
      },
    },
  },
});

export const sprinkles = createSprinkles(layoutProperties, themeProperties);
