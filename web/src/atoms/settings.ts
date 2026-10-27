import { createStore, entries, set } from "idb-keyval";
import { atom, type SetStateAction, type WritableAtom } from "jotai";

// Per-browser preferences (sidebar, open tabs, wallpaper layout) live in IndexedDB. idb-keyval
// creates its object store only when it creates the database, and "andrewix" already holds the
// favorites, so the settings get a database of their own.
const db = createStore("andrewix-settings", "settings");

// Every stored setting as read at start-up, then every write since. Atoms read it synchronously,
// so their first render already shows the stored value instead of flashing the default.
const cache = new Map<string, unknown>();

let preloaded: Promise<void> | undefined;

/**
 * Reads every stored setting into memory, once. The root route waits for it before rendering.
 * IndexedDB can be blocked (private windows, cleared site data); the settings then start from
 * their defaults and still work for this session.
 */
export function preloadSettings(): Promise<void> {
  // idb-keyval opens the database inside the call, so a missing `indexedDB` throws instead of
  // rejecting; starting from a resolved promise turns both into a rejection.
  preloaded ??= Promise.resolve()
    .then(() => entries<string, unknown>(db))
    .then((pairs) => {
      for (const [key, value] of pairs) cache.set(key, value);
    })
    .catch(() => {
      // Nothing stored to read.
    });
  return preloaded;
}

interface Change {
  key: string;
  value: unknown;
}

let channel: BroadcastChannel | undefined;

// Other tabs hear about each write and show it too. A channel never receives its own messages.
function settingsChannel(): BroadcastChannel | undefined {
  if (typeof BroadcastChannel === "undefined") return undefined;
  channel ??= new BroadcastChannel("andrewix-settings");
  return channel;
}

/**
 * A setting kept in IndexedDB, read from the preloaded cache. Storage is editable by hand, so a
 * stored value that `isValid` rejects reads as the initial value instead.
 */
export function atomWithSetting<T>(
  key: string,
  initialValue: T,
  isValid: (value: unknown) => value is T,
): WritableAtom<T, [SetStateAction<T>], void> {
  // Bumped on each write, here or in another tab, so the setting reads the cache again.
  const version = atom(0);
  version.onMount = (bump) => {
    const onMessage = ({ data }: MessageEvent<Change>) => {
      if (data.key !== key) return;
      cache.set(key, data.value);
      bump((count) => count + 1);
    };
    const controller = new AbortController();
    settingsChannel()?.addEventListener("message", onMessage, {
      signal: controller.signal,
    });
    return () => controller.abort();
  };

  const setting = atom(
    (get) => {
      get(version);
      const value = cache.get(key);
      return isValid(value) ? value : initialValue;
    },
    (get, write, update: SetStateAction<T>) => {
      const next =
        typeof update === "function"
          ? (update as (prev: T) => T)(get(setting))
          : update;
      cache.set(key, next);
      write(version, (count) => count + 1);
      settingsChannel()?.postMessage({ key, value: next } satisfies Change);
      Promise.resolve()
        .then(() => set(key, next, db))
        .catch(() => {
          // Not persisted; still applied for this session.
        });
    },
  );
  return setting;
}
