import type { ReactNode } from "react";
import type { ThemeMode } from "../atoms/theme";
import * as s from "./ThemeScope.css";

interface ThemeScopeProps {
  theme: ThemeMode;
  children: ReactNode;
}

/** Renders children in a fixed theme, regardless of the page's current theme. */
export function ThemeScope({ theme, children }: ThemeScopeProps) {
  return (
    <div data-theme={theme} className={s.scope}>
      {children}
    </div>
  );
}
