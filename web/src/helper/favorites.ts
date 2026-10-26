import type { Wall } from "@/data/walls";

/** Key of one wallpaper, unique across sources: its source, then its path. */
export const wallId = (wall: Wall): string => `${wall.source}/${wall.path}`;

/**
 * The favorite ids out of a stored value. Storage is editable by hand, so anything that is not a
 * list of strings reads as no favorites, and stray entries are dropped.
 */
export function parseFavorites(value: unknown): ReadonlySet<string> {
  if (!Array.isArray(value)) return new Set();
  return new Set(value.filter((id): id is string => typeof id === "string"));
}

/** The favorites with one id added, or removed if it was there. */
export function toggled(
  favorites: ReadonlySet<string>,
  id: string,
): ReadonlySet<string> {
  const next = new Set(favorites);
  if (!next.delete(id)) next.add(id);
  return next;
}
