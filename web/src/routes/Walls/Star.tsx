import {
  ToggleButton,
  type ToggleButtonProps,
} from "react-aria-components/ToggleButton";
import { Icons } from "@/ui";
import { type StarVariants, star } from "./Star.css";

interface StarProps extends Omit<ToggleButtonProps, "className" | "children"> {
  /** What pressing the star does, since it shows no text. */
  "aria-label": string;
  variant?: StarVariants["variant"];
}

/** Star that is filled while on, for favoriting a wallpaper or filtering by favorites. */
export function Star({ variant, ...rest }: StarProps) {
  return (
    <ToggleButton className={star({ variant })} {...rest}>
      {({ isSelected }) =>
        isSelected ? (
          <Icons.Favorite aria-hidden />
        ) : (
          <Icons.NotFavorite aria-hidden />
        )
      }
    </ToggleButton>
  );
}
