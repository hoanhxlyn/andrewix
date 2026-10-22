import type { ComponentPropsWithoutRef } from "react";
import type { ThemeMode } from "../../atoms/theme";
import * as s from "./ThemeScope.css";

interface ThemeScopeProps
  extends Omit<ComponentPropsWithoutRef<"div">, "className"> {
  theme: ThemeMode;
}

/** Renders children in a fixed theme, regardless of the page's current theme. */
export function ThemeScope({ theme, ...rest }: ThemeScopeProps) {
  return <div className={s.scope} {...rest} data-theme={theme} />;
}
