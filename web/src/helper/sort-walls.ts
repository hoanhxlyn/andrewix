import type { Sort } from "@/constants";
import type { Wall } from "@/data/walls";
import { wallId } from "@/helper/favorites";

/** A path without the extension of its name, folders kept. */
export const withoutExtension = (path: string): string =>
  path.replace(/\.[^./]*$/, "");

/** Name of a wallpaper, the last segment of its path without its extension. */
export const nameOf = (path: string): string =>
  withoutExtension(path.slice(path.lastIndexOf("/") + 1));

/** Compares wallpaper names as people read them, so `wall2` comes before `wall10`. */
export const byName = (a: Wall, b: Wall): number =>
  nameOf(a.path).localeCompare(nameOf(b.path), "en", { numeric: true });

/** Compares sources, keeping each source's wallpapers in name order. */
const bySource = (a: Wall, b: Wall): number =>
  a.source.localeCompare(b.source, "en", { numeric: true }) || byName(a, b);

/** Compares favorites first, keeping each side in name order. */
const byFavorite =
  (favorites: ReadonlySet<string>) =>
  (a: Wall, b: Wall): number =>
    Number(favorites.has(wallId(b))) - Number(favorites.has(wallId(a))) ||
    byName(a, b);

/** The wallpapers in a sort order; without one they keep the order of their sources. */
export function sorted(
  walls: Wall[],
  sort: Sort | null,
  favorites: ReadonlySet<string>,
): Wall[] {
  if (sort === null) return walls;
  const compare =
    sort.column === "name"
      ? byName
      : sort.column === "source"
        ? bySource
        : byFavorite(favorites);
  const ordered = [...walls].sort(compare);
  return sort.order === "asc" ? ordered : ordered.reverse();
}
