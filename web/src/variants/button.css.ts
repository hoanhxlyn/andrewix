import { globalStyle } from "@vanilla-extract/css";
import { type RecipeVariants, recipe } from "@vanilla-extract/recipes";
import { inComponents } from "../styles/layers.css";
import { text, vars } from "../styles/tokens.css";
import { stateLayer } from "./stateLayer.css";

const onSurfaceAt = (amount: string) =>
  `color-mix(in srgb, ${vars.color.onSurface} calc(${amount} * 100%), transparent)`;

const disabledContainer = onSurfaceAt(vars.state.disabledContainer);
const disabledContent = onSurfaceAt(vars.state.disabledContent);

/** Button with a text label. */
export const button = recipe({
  base: [
    stateLayer,
    inComponents({
      ...text.label,
      appearance: "none",
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      gap: vars.space.sm,
      height: vars.size.control,
      padding: `0 ${vars.space.xl}`,
      border: `${vars.border.outline} solid transparent`,
      borderRadius: vars.shape.full,
      cursor: "pointer",
      selectors: {
        "&:disabled": { cursor: "not-allowed", color: disabledContent },
      },
    }),
  ],
  variants: {
    variant: {
      filled: inComponents({
        background: vars.color.primary,
        color: vars.color.onPrimary,
        selectors: { "&:disabled": { background: disabledContainer } },
      }),
      tonal: inComponents({
        background: vars.color.primaryContainer,
        color: vars.color.onPrimaryContainer,
        selectors: { "&:disabled": { background: disabledContainer } },
      }),
      outlined: inComponents({
        background: "transparent",
        color: vars.color.primary,
        borderColor: vars.color.outline,
        selectors: { "&:disabled": { borderColor: disabledContainer } },
      }),
      text: inComponents({
        background: "transparent",
        color: vars.color.primary,
        padding: `0 ${vars.space.md}`,
      }),
    },
  },
  defaultVariants: { variant: "filled" },
});

/** Variant props accepted by `button`. */
export type ButtonVariants = NonNullable<RecipeVariants<typeof button>>;

globalStyle(
  `${button.classNames.base} svg`,
  inComponents({ width: vars.size.icon, height: vars.size.icon }),
);
