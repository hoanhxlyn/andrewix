import { useAtom } from "jotai";
import DarkIcon from "~icons/material-symbols/dark-mode-outline-rounded";
import LightIcon from "~icons/material-symbols/light-mode-outline-rounded";
import { themeAtom } from "../../atoms/theme";
import { Button } from "../Button";

export function ThemeToggle() {
  const [mode, setMode] = useAtom(themeAtom);
  const isDark = mode === "dark";
  const nextMode = isDark ? "light" : "dark";
  return (
    <Button
      variant="icon"
      aria-label={`Theme: ${mode}. Switch to ${nextMode}`}
      title={`Theme: ${mode}`}
      onClick={() => setMode(nextMode)}
    >
      {isDark ? <DarkIcon aria-hidden /> : <LightIcon aria-hidden />}
    </Button>
  );
}
