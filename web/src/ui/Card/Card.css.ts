import { type RecipeVariants, recipe } from "@vanilla-extract/recipes";
import { inComponents } from "../../styles/layers.css";
import { sprinkles } from "../../styles/sprinkles.css";
import { text } from "../../styles/tokens.css";

/** Card container for grouped content. */
export const card = recipe({
  base: [
    inComponents(text.body),
    sprinkles({
      padding: "lg",
      background: "surface",
      color: "onSurface",
      borderRadius: "medium",
    }),
  ],
  variants: {
    variant: {
      elevated: sprinkles({ boxShadow: "level1" }),
      outlined: sprinkles({ border: "outline" }),
    },
  },
  defaultVariants: { variant: "elevated" },
});

/** Variant props accepted by `card`. */
export type CardVariants = NonNullable<RecipeVariants<typeof card>>;
