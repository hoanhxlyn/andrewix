import { useAtom } from "jotai";
import { themeAtom } from "@/atoms/theme";
import { Button } from "@/ui/Button";
import DarkIcon from "~icons/material-symbols/dark-mode-outline-rounded";
import LightIcon from "~icons/material-symbols/light-mode-outline-rounded";

export function ThemeToggle() {
  const [mode, setMode] = useAtom(themeAtom);
  const isDark = mode === "dark";
  const nextMode = isDark ? "light" : "dark";
  return (
    <Button
      variant="icon"
      icon={isDark ? <DarkIcon /> : <LightIcon />}
      aria-label={`Theme: ${mode}. Switch to ${nextMode}`}
      onPress={() => setMode(nextMode)}
    />
  );
}
