import { atom } from "jotai";
import type { Key } from "react-aria-components/Tree";

// Paths of the folders open in the file tree. Kept outside the component so they survive the
// tree unmounting, which happens whenever the sidebar is hidden.
export const openedFoldersAtom = atom<Set<Key>>(new Set<Key>());
