import { atomWithStorage } from "jotai/utils";

// Repository paths of the files open as tabs, in tab order. Remembered per browser, not in the
// URL: a shared link shows one file, not the tabs someone happened to have open.
export const openFilesAtom = atomWithStorage<string[]>(
  "open-files",
  [],
  undefined,
  { getOnInit: true },
);

// Whether markdown files show rendered instead of as source, remembered per browser.
export const markdownPreviewAtom = atomWithStorage<boolean>(
  "markdown-preview",
  true,
  undefined,
  { getOnInit: true },
);

// Whether long lines wrap to the pane, remembered per browser as a reading preference.
export const wrapLinesAtom = atomWithStorage<boolean>(
  "wrap-lines",
  false,
  undefined,
  { getOnInit: true },
);
