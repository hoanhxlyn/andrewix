import {
  atomWithStorage,
  createJSONStorage,
  unstable_withStorageValidator as withStorageValidator,
} from "jotai/utils";
import { isBoolean, isString } from "remeda";

// Storage is editable by hand, so a stored value that is not in the shape written reads as the
// initial value instead.
const booleanStorage = withStorageValidator(isBoolean)(createJSONStorage());
const pathsStorage = withStorageValidator(
  (value): value is string[] => Array.isArray(value) && value.every(isString),
)(createJSONStorage());

// Repository paths of the files open as tabs, in tab order. Remembered per browser, not in the
// URL: a shared link shows one file, not the tabs someone happened to have open.
export const openFilesAtom = atomWithStorage<string[]>(
  "open-files",
  [],
  pathsStorage,
  { getOnInit: true },
);

// Whether markdown files show rendered instead of as source, remembered per browser.
export const markdownPreviewAtom = atomWithStorage<boolean>(
  "markdown-preview",
  true,
  booleanStorage,
  { getOnInit: true },
);

// Whether long lines wrap to the pane, remembered per browser as a reading preference.
export const wrapLinesAtom = atomWithStorage<boolean>(
  "wrap-lines",
  false,
  booleanStorage,
  { getOnInit: true },
);
