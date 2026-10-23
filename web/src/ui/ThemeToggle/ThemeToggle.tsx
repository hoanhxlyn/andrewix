import { useAtom } from "jotai";
import { themeAtom } from "@/atoms/theme";
import { Button } from "@/ui/Button";
import Icons from "@/ui/Icon";

export function ThemeToggle() {
  const [mode, setMode] = useAtom(themeAtom);
  const isDark = mode === "dark";
  const nextMode = isDark ? "light" : "dark";
  return (
    <Button
      variant="icon"
      icon={isDark ? <Icons.Dark /> : <Icons.Light />}
      aria-label={`Theme: ${mode}. Switch to ${nextMode}`}
      onPress={() => setMode(nextMode)}
    />
  );
}
