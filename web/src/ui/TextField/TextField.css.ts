import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";

/** Column of a text input and its label. */
export const field = style([
  sprinkles({ display: "flex", flexDirection: "column", gap: "xs" }),
  inComponents({ minWidth: 0 }),
]);

/** Label over the input, in the small type Material gives a supporting label. */
export const label = style(
  inComponents({ ...text.label, color: vars.color.onSurfaceVariant }),
);

/** The input itself, outlined and filled like Material's outlined text field. */
export const input = style(
  inComponents({
    ...text.body,
    height: vars.size.control,
    paddingInline: vars.space.lg,
    borderRadius: vars.shape.extraSmall,
    border: `${vars.border.outline} solid ${vars.color.outline}`,
    background: "transparent",
    color: vars.color.onSurface,
    caretColor: vars.color.primary,
    outline: "none",
    selectors: {
      "&:focus-visible, &[data-focus-visible]": {
        borderColor: vars.color.primary,
      },
      "&::placeholder": { color: vars.color.onSurfaceVariant, opacity: 1 },
    },
  }),
);
