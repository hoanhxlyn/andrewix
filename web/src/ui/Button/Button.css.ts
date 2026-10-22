import { globalStyle } from "@vanilla-extract/css";
import { type RecipeVariants, recipe } from "@vanilla-extract/recipes";
import { inComponents } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { text, vars } from "@/styles/tokens.css";
import { stateLayer } from "@/ui/shared/stateLayer.css";

const onSurfaceAt = (amount: string) =>
  `color-mix(in srgb, ${vars.color.onSurface} calc(${amount} * 100%), transparent)`;

const disabledContainer = onSurfaceAt(vars.state.disabledContainer);
const disabledContent = onSurfaceAt(vars.state.disabledContent);

/** Button with a text label or, with the `icon` variant, only an icon. */
export const button = recipe({
  base: [
    stateLayer,
    sprinkles({
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      gap: "sm",
      borderRadius: "full",
    }),
    inComponents({
      ...text.label,
      appearance: "none",
      height: vars.size.control,
      padding: `0 ${vars.space.xl}`,
      border: `${vars.border.outline} solid transparent`,
      cursor: "pointer",
      selectors: {
        "&[data-disabled]": { cursor: "not-allowed", color: disabledContent },
      },
    }),
  ],
  variants: {
    variant: {
      filled: inComponents({
        background: vars.color.primary,
        color: vars.color.onPrimary,
        selectors: { "&[data-disabled]": { background: disabledContainer } },
      }),
      tonal: inComponents({
        background: vars.color.primaryContainer,
        color: vars.color.onPrimaryContainer,
        selectors: { "&[data-disabled]": { background: disabledContainer } },
      }),
      outlined: inComponents({
        background: "transparent",
        color: vars.color.primary,
        borderColor: vars.color.outline,
        selectors: { "&[data-disabled]": { borderColor: disabledContainer } },
      }),
      text: inComponents({
        background: "transparent",
        color: vars.color.primary,
        padding: `0 ${vars.space.md}`,
      }),
      icon: inComponents({
        width: vars.size.control,
        padding: 0,
        background: "transparent",
        color: vars.color.onSurfaceVariant,
      }),
    },
  },
  defaultVariants: { variant: "filled" },
});

/** Variant props accepted by `button`. */
export type ButtonVariants = NonNullable<RecipeVariants<typeof button>>;

globalStyle(
  `${button.classNames.base} > svg`,
  inComponents({ width: vars.size.icon, height: vars.size.icon }),
);
