import { createStore, get, update } from "idb-keyval";
import { atom } from "jotai";
import { parseFavorites, toggled } from "@/helper/favorites";

// Favorites stay in this browser's IndexedDB, as one list of wallpaper ids under one key. Like the
// sidebar width they describe one person's taste rather than what a shared link shows.
const db = createStore("andrewix", "favorites");
const KEY = "walls";

const stored = atom<ReadonlySet<string>>(new Set<string>());

// Read once the first component that shows favorites mounts. IndexedDB can be blocked (private
// windows, cleared site data), in which case favorites still work for this session only.
// idb-keyval opens the database inside the call, so a missing `indexedDB` throws instead of
// rejecting; starting from a resolved promise turns both into a rejection.
stored.onMount = (setStored) => {
  Promise.resolve()
    .then(() => get(KEY, db))
    .then((value) => setStored(parseFavorites(value)))
    .catch(() => {
      // Nothing stored to show.
    });
};

/** Ids of the favorite wallpapers; writing an id toggles it. */
export const favoritesAtom = atom(
  (read) => read(stored),
  (read, write, id: string) => {
    // Shown at once, then written as a toggle of what is stored rather than a copy of the set in
    // memory: a toggle made before the first read lands must not wipe the stored favorites.
    write(stored, toggled(read(stored), id));
    let saved: ReadonlySet<string> = new Set();
    Promise.resolve()
      .then(() =>
        update(
          KEY,
          (value) => {
            saved = toggled(parseFavorites(value), id);
            return [...saved];
          },
          db,
        ),
      )
      .then(() => write(stored, saved))
      .catch(() => {
        // Not persisted; still applied for this session.
      });
  },
);
