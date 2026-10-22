import type { ComponentPropsWithoutRef } from "react";
import type { ThemeMode } from "@/atoms/theme";
import { sprinkles } from "@/styles/sprinkles.css";

interface ThemeScopeProps
  extends Omit<ComponentPropsWithoutRef<"div">, "className"> {
  theme: ThemeMode;
}

/** Renders children in a fixed theme, regardless of the page's current theme. */
export function ThemeScope({ theme, ...rest }: ThemeScopeProps) {
  return (
    <div
      className={sprinkles({
        padding: "xl",
        borderRadius: "large",
        background: "background",
        color: "onSurface",
      })}
      {...rest}
      data-theme={theme}
    />
  );
}
