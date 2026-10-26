import {
  createSerializer,
  parseAsBoolean,
  parseAsString,
  parseAsStringEnum,
  type UrlKeys,
  useQueryStates,
} from "nuqs";
import { SORTS, SOURCES } from "@/constants";

// The filter and the sort order live in the URL, so opening a wallpaper's dialog and closing it
// again lands back on the same grid, and a link carries them all.
const params = {
  search: parseAsString,
  source: parseAsStringEnum([...SOURCES]),
  sort: parseAsStringEnum([...SORTS]),
  favorites: parseAsBoolean,
};

const urlKeys: UrlKeys<typeof params> = {
  search: "q",
  source: "s",
  sort: "o",
  favorites: "f",
};

// Built from the filter values themselves: nuqs writes the URL without the router noticing, so
// `useLocation()` would hand back a stale query.
export const serialize = createSerializer(params, { urlKeys });

/**
 * The search, source and favorites filters and the sort order of the wallpaper grid, read from and
 * written to the URL.
 */
export function useWallsState() {
  return useQueryStates(params, { urlKeys });
}
