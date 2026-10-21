import {
  type GlobalStyleRule,
  layer,
  type StyleRule,
} from "@vanilla-extract/css";

// Cascade order, lowest to highest: element defaults, component styles, then utilities, so a
// sprinkle always beats a component rule no matter which file is emitted first.
export const base = layer("base");
export const components = layer("components");
export const utilities = layer("utilities");

export const inBase = (rule: GlobalStyleRule) => ({
  "@layer": { [base]: rule },
});

export const inComponents = (rule: StyleRule) => ({
  "@layer": { [components]: rule },
});
