// Apply the theme before first paint: the stored choice, else the OS preference.
let mode = matchMedia("(prefers-color-scheme: dark)").matches
  ? "dark"
  : "light";
try {
  const stored = localStorage.getItem("theme");
  if (stored === "light" || stored === "dark") mode = stored;
} catch {}
document.documentElement.dataset.theme = mode;
