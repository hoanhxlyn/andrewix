import { globalStyle, type StyleRule, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Scrollable pane holding a rendered markdown file. */
export const frame = style(
  inComponents({
    flex: 1,
    minHeight: 0,
    overflow: "auto",
    paddingBlock: vars.space.lg,
    paddingInline: vars.space.xl,
    background: vars.color.surface,
    color: vars.color.onSurface,
  }),
);

/** The rendered document, kept to a readable line length. */
export const prose = style(
  inComponents({ ...text.body, maxWidth: vars.size.prose }),
);

// The elements come from react-markdown, so they are styled from the document class down.
const inProse = (selector: string, rule: StyleRule) =>
  globalStyle(`${prose} ${selector}`, inComponents(rule));

inProse("> :first-child", { marginBlockStart: 0 });
inProse("> :last-child", { marginBlockEnd: 0 });

inProse("h1", {
  ...text.headline,
  marginBlock: `${vars.space.xl} ${vars.space.md}`,
});
inProse("h2", {
  ...text.title,
  marginBlock: `${vars.space.xl} ${vars.space.sm}`,
  paddingBlockEnd: vars.space.xs,
  borderBlockEnd: `${vars.border.outline} solid ${vars.color.outline}`,
});
inProse("h3, h4, h5, h6", {
  ...text.label,
  marginBlock: `${vars.space.lg} ${vars.space.sm}`,
});
inProse("p, ul, ol, blockquote, table", { marginBlock: vars.space.md });
inProse("ul, ol", { paddingInlineStart: vars.space.xl });
inProse("li + li", { marginBlockStart: vars.space.xs });

inProse("a", {
  color: vars.color.primary,
  textUnderlineOffset: vars.border.focusRing,
});

inProse("blockquote", {
  marginInline: 0,
  paddingInlineStart: vars.space.md,
  borderInlineStart: `${vars.border.indicator} solid ${vars.color.outline}`,
  color: vars.color.onSurfaceVariant,
});

inProse(":not(pre) > code", {
  paddingInline: vars.space.xs,
  borderRadius: vars.shape.small,
  background: vars.color.surfaceVariant,
  fontFamily: vars.typeface.mono,
});

inProse("pre", {
  marginBlock: vars.space.md,
  padding: vars.space.md,
  // Shiki's background matches the pane, so the outline is what sets the block apart.
  border: `${vars.border.outline} solid ${vars.color.outline}`,
  borderRadius: vars.shape.medium,
  overflowX: "auto",
  fontFamily: vars.typeface.mono,
});

inProse("table", { borderCollapse: "collapse" });
inProse("th, td", {
  paddingBlock: vars.space.xs,
  paddingInline: vars.space.sm,
  border: `${vars.border.outline} solid ${vars.color.outline}`,
  textAlign: "start",
});

// Shiki stamps light-theme colors inline on each block and token; the dark pair lives in
// --shiki-dark and --shiki-dark-bg, so only an !important rule can switch it per theme.
globalStyle(`[data-theme="dark"] ${prose} .shiki`, {
  backgroundColor: "var(--shiki-dark-bg) !important",
});
globalStyle(
  `[data-theme="dark"] ${prose} .shiki, [data-theme="dark"] ${prose} .shiki span`,
  { color: "var(--shiki-dark) !important" },
);
