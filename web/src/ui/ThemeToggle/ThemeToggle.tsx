import { useAtom } from "jotai";
import { themeAtom } from "@/atoms/theme";
import { Button } from "@/ui/Button";
import DarkIcon from "~icons/mdi/weather-night";
import LightIcon from "~icons/mdi/white-balance-sunny";

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
