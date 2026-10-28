import { createStore, get, set, update } from "idb-keyval";
import { atom } from "jotai";
import { parseFavorites, withFavorite } from "@/helper/favorites";
import { atomWithSetting } from "./settings";

// Favorites stay in this browser's IndexedDB, as one list of wallpaper ids under one key. Like the
// sidebar width they describe one person's taste rather than what a shared link shows.
const db = createStore("andrewix", "favorites");
const KEY = "walls";

const stored = atom<ReadonlySet<string>>(new Set<string>());

// The first read of what is stored has landed, either way. Until it has, the dialog cannot show
// the favorites a replace would drop, so it offers none.
let readDone = false;
let notifyReady: (() => void) | undefined;

/** Set once the first read of the stored favorites has landed. */
export const favoritesReadyAtom = atom(false);
favoritesReadyAtom.onMount = (setReady) => {
  const bump = () => setReady(true);
  if (readDone) bump();
  else notifyReady = bump;
  return () => {
    if (notifyReady === bump) notifyReady = undefined;
  };
};

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
    })
    .finally(() => {
      readDone = true;
      notifyReady?.();
    });
};

/** Ids of the favorite wallpapers; writing an id toggles it. */
export const favoritesAtom = atom(
  (read) => read(stored),
  (read, write, id: string) => {
    // The user adds or removes what they see. Shown at once, then that one change is applied to
    // what is stored rather than a copy of the set in memory: a change made before the first read
    // lands must not wipe the stored favorites, and another tab may have changed them since.
    const favorite = !read(stored).has(id);
    write(stored, withFavorite(read(stored), id, favorite));
    let saved: ReadonlySet<string> = new Set();
    Promise.resolve()
      .then(() =>
        update(
          KEY,
          (value) => {
            saved = withFavorite(parseFavorites(value), id, favorite);
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

/** What an imported file brings: its ids, and whether they replace the favorites or add to them. */
interface Import {
  ids: ReadonlySet<string>;
  replace: boolean;
}

/**
 * Applies an imported file to the favorites, in place of the one-by-one toggle. Shown at once,
 * then written; the write is awaited, and its failure reaches the caller, so nothing reports a
 * save that did not happen. The read is taken fresh rather than from memory: the dialog can be
 * open before the first read lands, and another tab may have starred since.
 */
export const importFavoritesAtom = atom(
  null,
  async (get, write, { ids, replace }: Import) => {
    const current = await Promise.resolve()
      .then(() => get(KEY, db))
      .then(parseFavorites)
      .catch(() => get(stored));
    const next = replace ? ids : new Set([...current, ...ids]);
    write(stored, next);
    await set(KEY, [...next], db);
  },
);

/** When the favorites were last written to a file, and how many the file held. */
export interface LastExport {
  at: number;
  count: number;
}

const isLastExport = (value: unknown): value is LastExport | null =>
  value === null ||
  (typeof value === "object" &&
    value !== null &&
    typeof (value as LastExport).at === "number" &&
    typeof (value as LastExport).count === "number");

/** The last export, so the dialog can say when the file someone holds was written. */
export const lastExportAtom = atomWithSetting<LastExport | null>(
  "walls-favorites-export",
  null,
  isLastExport,
);
