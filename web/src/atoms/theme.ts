import { getDefaultStore } from "jotai";
import { atomWithStorage } from "jotai/utils";

export type ThemeMode = "light" | "dark";

// jotai does not export its storage types, so take the sync overload's parameter type.
type ThemeStorage = NonNullable<
  Parameters<typeof atomWithStorage<ThemeMode>>[2]
>;

const STORAGE_KEY = "theme";

function systemMode(): ThemeMode {
  const prefersDark =
    typeof matchMedia === "function" &&
    matchMedia("(prefers-color-scheme: dark)").matches;
  return prefersDark ? "dark" : "light";
}

function parseMode(value: string | null): ThemeMode {
  return value === "light" || value === "dark" ? value : systemMode();
}

// Plain-string storage so `public/theme-init.js` can read the same value. With nothing stored,
// the OS preference decides. Storage can be blocked, so every access falls back or is skipped.
const storage: ThemeStorage = {
  getItem(key) {
    try {
      return parseMode(localStorage.getItem(key));
    } catch {
      return systemMode();
    }
  },
  setItem(key, mode) {
    try {
      localStorage.setItem(key, mode);
    } catch {
      // Not persisted; still applied for this session.
    }
  },
  removeItem(key) {
    try {
      localStorage.removeItem(key);
    } catch {
      // Nothing to remove.
    }
  },
  subscribe(key, callback) {
    if (typeof window === "undefined") return;
    const onStorage = (e: StorageEvent) => {
      if (e.storageArea === localStorage && e.key === key) {
        callback(parseMode(e.newValue));
      }
    };
    const controller = new AbortController();
    window.addEventListener("storage", onStorage, {
      signal: controller.signal,
    });
    return () => controller.abort();
  },
};

export const themeAtom = atomWithStorage<ThemeMode>(
  STORAGE_KEY,
  "light",
  storage,
  { getOnInit: true },
);

// Keep <html data-theme> in sync. `theme-init.js` already applied the initial value before
// first paint, so only later changes (toggle, other tabs) need handling here.
const store = getDefaultStore();

store.sub(themeAtom, () => {
  document.documentElement.dataset.theme = store.get(themeAtom);
});
