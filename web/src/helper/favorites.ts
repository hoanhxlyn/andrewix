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

/** The favorites with one id added, or removed when `favorite` is false. */
export function withFavorite(
  favorites: ReadonlySet<string>,
  id: string,
  favorite: boolean,
): ReadonlySet<string> {
  const next = new Set(favorites);
  if (favorite) next.add(id);
  else next.delete(id);
  return next;
}
