import type { Sort } from "@/constants";
import type { Wall } from "@/data/walls";

/** Name of a wallpaper, the last segment of its path. */
export const nameOf = (path: string): string =>
  path.slice(path.lastIndexOf("/") + 1);

/** Compares wallpaper names as people read them, so `wall2` comes before `wall10`. */
export const byName = (a: Wall, b: Wall): number =>
  nameOf(a.path).localeCompare(nameOf(b.path), "en", { numeric: true });

/** The wallpapers in a sort order; without one they keep the order of their sources. */
export function sorted(walls: Wall[], sort: Sort | null): Wall[] {
  if (sort === null) return walls;
  const ascending = [...walls].sort(byName);
  return sort === "az" ? ascending : ascending.reverse();
}
