import { useAtom } from "jotai";
import type { ComponentType, SVGProps } from "react";
import DarkIcon from "~icons/material-symbols/dark-mode-outline-rounded";
import LightIcon from "~icons/material-symbols/light-mode-outline-rounded";
import { type ThemeMode, themeAtom } from "../atoms/theme";
import { IconButton } from "./IconButton";

const icons: Record<ThemeMode, ComponentType<SVGProps<SVGSVGElement>>> = {
  light: LightIcon,
  dark: DarkIcon,
};

const next: Record<ThemeMode, ThemeMode> = {
  light: "dark",
  dark: "light",
};

export function ThemeToggle() {
  const [mode, setMode] = useAtom(themeAtom);
  const Icon = icons[mode];
  return (
    <IconButton
      label={`Theme: ${mode}. Switch to ${next[mode]}`}
      title={`Theme: ${mode}`}
      onClick={() => setMode(next[mode])}
    >
      <Icon aria-hidden />
    </IconButton>
  );
}
