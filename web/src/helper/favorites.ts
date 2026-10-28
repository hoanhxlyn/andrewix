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

/**
 * A favorites file: the ids as a JSON list, one per line, so a person can read and edit it.
 */
export function serializeFavorites(favorites: ReadonlySet<string>): string {
  return `${JSON.stringify([...favorites], null, 2)}\n`;
}

const isId = (value: unknown): value is string =>
  typeof value === "string" && value !== "";

/**
 * The ids in the text of a favorites file, or null when it is not one. A file is refused whole
 * rather than read in part: an id a file gets wrong must not pass for an empty list, which an
 * overwrite would then take as the favorites to keep.
 */
export function readFavoriteFile(text: string): ReadonlySet<string> | null {
  try {
    const value: unknown = JSON.parse(text);
    return Array.isArray(value) && value.every(isId) ? new Set(value) : null;
  } catch {
    return null;
  }
}

/** Whether both sets hold the same ids, in any order. */
export function sameFavorites(
  a: ReadonlySet<string>,
  b: ReadonlySet<string>,
): boolean {
  return a.size === b.size && [...a].every((id) => b.has(id));
}

/** A name as a file name: lowercase words joined by dashes, ending in `.json`. */
export function favoriteFileName(name: string): string {
  const slug = name
    .toLowerCase()
    .normalize("NFKD")
    // Accents come apart from their letter here, so they can be dropped as not a word.
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return `${slug === "" ? "favorites" : slug}.json`;
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
