import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Box of the favorites dialog. */
export const modal = style(
  inComponents({
    width: `min(100%, ${vars.size.dialog})`,
    borderRadius: vars.shape.extraLarge,
  }),
);

/** Bar of the dialog, holding its heading and the button that closes it. */
export const header = style([
  sprinkles({ display: "flex", alignItems: "center", gap: "sm" }),
  inComponents({
    paddingBlock: vars.space.md,
    paddingInlineStart: vars.space.xl,
    paddingInlineEnd: vars.space.md,
  }),
]);

/** Heading of the dialog. */
export const title = style(inComponents({ ...text.title, flex: 1 }));

/** Middle of the dialog: what the browser holds, then the two ways to move it. */
export const body = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "lg" }),
  inComponents({
    paddingBlockEnd: vars.space.sm,
    paddingInline: vars.space.xl,
  }),
]);

/** Row holding the export and import buttons. */
export const actions = sprinkles({
  display: "flex",
  flexWrap: "wrap",
  alignItems: "center",
  gap: "md",
});

/** A line of the dialog that says what the favorites amount to. */
export const line = style(
  inComponents({ ...text.body, color: vars.color.onSurfaceVariant }),
);

/** Line saying the picked file is not one, in place of the import preview. */
export const error = style(
  inComponents({ ...text.body, color: vars.color.primary }),
);

/** Row of the dialog's buttons, trailing as in a Material dialog. */
export const footer = style([
  sprinkles({ display: "flex", justifyContent: "flex-end", gap: "sm" }),
  inComponents({
    paddingBlock: vars.space.md,
    paddingInline: vars.space.xl,
  }),
]);

/** The choice between merging the file and overwriting with it. */
export const modes = style(inComponents({ width: "100%" }));
