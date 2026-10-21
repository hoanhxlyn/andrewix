import {
  assignVars,
  createGlobalTheme,
  globalStyle,
} from "@vanilla-extract/css";
import { inBase } from "./layers.css";
import { breakpoints, dark, light, text, themeVars, vars } from "./tokens.css";

// The selectors also match nested elements, so a subtree can force a theme (used by the
// design catalog to show both side by side). `themeVars` is the contract both modes implement.
const darkScope = ':root[data-theme="dark"], :root [data-theme="dark"]';
const lightScope = ':root[data-theme="light"], :root [data-theme="light"]';

createGlobalTheme(darkScope, themeVars, dark);
createGlobalTheme(lightScope, themeVars, light);
globalStyle(darkScope, { colorScheme: "dark" });
globalStyle(lightScope, { colorScheme: "light" });

// Layout grid per window class: more columns and wider margins as the window grows.
const wide = { margin: vars.space.xl, gutter: vars.space.xl };

globalStyle(":root", {
  "@media": {
    [breakpoints.medium]: {
      vars: assignVars(vars.layout, { columns: "8", ...wide }),
    },
    [breakpoints.expanded]: {
      vars: assignVars(vars.layout, { columns: "12", ...wide }),
    },
  },
});

// The transition softens theme switches and hover states. The stored theme is applied before
// first paint, so it does not animate the initial load.
globalStyle(
  "*, *::before, *::after",
  inBase({
    boxSizing: "border-box",
    transition: ["background-color", "border-color", "color", "box-shadow"]
      .map((p) => `${p} ${vars.motion.duration} ${vars.motion.easing}`)
      .join(", "),
    "@media": {
      "(prefers-reduced-motion: reduce)": { transition: "none" },
    },
  }),
);

globalStyle("html, body", inBase({ height: "100%" }));

globalStyle(
  "body",
  inBase({
    margin: 0,
    background: vars.color.background,
    color: vars.color.onSurface,
    fontFamily: vars.typeface.body,
    ...text.body,
  }),
);

globalStyle("a", inBase({ color: vars.color.primary }));

// Map Ondine's theme variables onto the app tokens so diagrams follow light and dark.
globalStyle(
  ".ondine",
  inBase({
    vars: {
      "--ondine-bg": "transparent",
      "--ondine-fg": vars.color.onSurface,
      "--ondine-muted": vars.color.onSurfaceVariant,
      "--ondine-line": vars.color.outline,
      "--ondine-border": vars.color.outline,
      "--ondine-surface": vars.color.primaryContainer,
      "--ondine-surface-alt": vars.color.surfaceVariant,
      "--ondine-accent": vars.color.primary,
      "--ondine-font": vars.typeface.body,
    },
  }),
);
