import { globalStyle } from "@vanilla-extract/css";
import { type RecipeVariants, recipe } from "@vanilla-extract/recipes";
import { inComponents, stateLayer } from "@/styles/layers.css";
import { sprinkles } from "@/styles/sprinkles.css";
import { vars } from "@/styles/tokens.css";

/** Toggle marking a wallpaper as a favorite, or showing only the favorites. */
export const star = recipe({
  base: [
    stateLayer,
    sprinkles({
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: "full",
    }),
    inComponents({
      appearance: "none",
      flexShrink: 0,
      padding: 0,
      border: "none",
      cursor: "pointer",
      color: vars.color.onSurfaceVariant,
      selectors: { "&[data-selected]": { color: vars.color.primary } },
    }),
  ],
  variants: {
    variant: {
      // In a toolbar or a header, beside other icon buttons.
      inline: inComponents({
        width: vars.size.control,
        height: vars.size.control,
        background: "transparent",
      }),
      // Over a picture, so it carries its own surface to stay readable.
      overlay: [
        sprinkles({ background: "surface", boxShadow: "level1" }),
        inComponents({
          width: vars.size.controlSmall,
          height: vars.size.controlSmall,
        }),
      ],
    },
  },
  defaultVariants: { variant: "inline" },
});

/** Variant props accepted by `star`. */
export type StarVariants = NonNullable<RecipeVariants<typeof star>>;

globalStyle(
  `${star.classNames.base} > svg`,
  inComponents({ width: vars.size.icon, height: vars.size.icon }),
);

globalStyle(
  `${star.classNames.variants.variant.overlay} > svg`,
  inComponents({ width: vars.size.iconSmall, height: vars.size.iconSmall }),
);
