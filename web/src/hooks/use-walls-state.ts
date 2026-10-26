import {
  createSerializer,
  parseAsString,
  parseAsStringEnum,
  type UrlKeys,
  useQueryStates,
} from "nuqs";
import { SOURCES } from "@/constants";

// The filter lives in the URL, so opening a wallpaper's dialog and closing it again lands back on
// the same selection, and a link carries both.
const params = {
  search: parseAsString,
  source: parseAsStringEnum([...SOURCES]),
};

const urlKeys: UrlKeys<typeof params> = { search: "q", source: "s" };

// Built from the filter values themselves: nuqs writes the URL without the router noticing, so
// `useLocation()` would hand back a stale query.
export const serialize = createSerializer(params, { urlKeys });

/** The search and source filter of the wallpaper grid, read from and written to the URL. */
export function useWallsState() {
  return useQueryStates(params, { urlKeys });
}
