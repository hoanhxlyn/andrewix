import { type RecipeVariants, recipe } from "@vanilla-extract/recipes";
import { inComponents } from "@/styles/layers.css";
import { text, vars } from "@/styles/tokens.css";

/** Small label naming or categorising the thing it sits on. */
export const pill = recipe({
  base: inComponents({
    ...text.label,
    flexShrink: 0,
    paddingInline: vars.space.sm,
    borderRadius: vars.shape.full,
  }),
  variants: {
    variant: {
      primary: inComponents({
        // Tinted fill: a wash of primary over the surface, with primary text on top.
        background: `color-mix(in oklab, ${vars.color.primary} 16%, transparent)`,
        color: vars.color.primary,
      }),
    },
  },
  defaultVariants: { variant: "primary" },
});

/** Variant props accepted by `pill`. */
export type PillVariants = NonNullable<RecipeVariants<typeof pill>>;
