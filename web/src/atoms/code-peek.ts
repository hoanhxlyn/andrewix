import { isBoolean, isString } from "remeda";
import { atomWithSetting } from "./settings";

const isPaths = (value: unknown): value is string[] =>
  Array.isArray(value) && value.every(isString);

// Repository paths of the files open as tabs, in tab order. Remembered per browser, not in the
// URL: a shared link shows one file, not the tabs someone happened to have open.
export const openFilesAtom = atomWithSetting<string[]>(
  "open-files",
  [],
  isPaths,
);

// Whether markdown files show rendered instead of as source, remembered per browser.
export const markdownPreviewAtom = atomWithSetting<boolean>(
  "markdown-preview",
  true,
  isBoolean,
);

// Whether long lines wrap to the pane, remembered per browser as a reading preference.
export const wrapLinesAtom = atomWithSetting<boolean>(
  "wrap-lines",
  false,
  isBoolean,
);
