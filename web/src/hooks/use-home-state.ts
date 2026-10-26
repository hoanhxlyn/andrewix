import {
  createSerializer,
  parseAsString,
  type UrlKeys,
  useQueryStates,
} from "nuqs";

// `file` and `search` share the page through the URL. The open tabs, the sidebar toggle and the
// line wrapping are kept per browser in atoms.
const params = {
  file: parseAsString,
  search: parseAsString,
};

/** One-letter keys keep the URL short; the code keeps the descriptive names. */
const urlKeys: UrlKeys<typeof params> = {
  file: "f",
  search: "q",
};

const serialize = createSerializer(params, { urlKeys });

/** URL of one file on its own, where a link opened in a new tab lands. */
export const hrefOf = (path: string) => serialize({ file: path });

/** The shown file and the tree search of the home page, read from and written to the URL. */
export function useHomeState() {
  return useQueryStates(params, { urlKeys });
}
