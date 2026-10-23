import { atom } from "jotai";
import type { Key } from "react-aria-components/Tree";

// Paths of the folders open in the file tree, kept outside the component so they survive it
// unmounting.
export const openedFoldersAtom = atom<Set<Key>>(new Set<Key>());
