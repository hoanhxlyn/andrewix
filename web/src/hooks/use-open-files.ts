import { tree } from "virtual:repo-tree";
import { useAtom } from "jotai";
import { openFilesAtom } from "@/atoms/code-peek";
import { filePaths } from "@/ui";
import { useHomeState } from "./use-home-state";

/** Every file of the repository tree, the only paths that can be open. */
export const FILES = new Set(filePaths(tree, ""));

/** The files open as tabs, and the actions that open, show and close them. */
export function useOpenFiles() {
  const [{ file }, setParams] = useHomeState();
  const [storedFiles, setOpenFiles] = useAtom(openFilesAtom);
  // Stored tabs or a link may repeat a file or name one the repository no longer has; pills need
  // unique, existing paths. A file opened from a link also shows as a pill.
  const open = [
    ...new Set([...storedFiles, ...(file === null ? [] : [file])]),
  ].filter((path) => FILES.has(path));
  const withOpened = (path: string) =>
    open.includes(path) ? open : [...open, path];

  /** Opens a file picked in the tree or a tab, and shows it. */
  const select = (path: string) => {
    setOpenFiles(withOpened(path));
    setParams({ file: path });
  };

  /**
   * Opens the file a link in the source points to, and shows it. Unlike picking in the tree, it
   * is a step the back button undoes.
   */
  const follow = (path: string) => {
    setOpenFiles(withOpened(path));
    setParams({ file: path }, { history: "push" });
  };

  /** Closes a tab. Closing the shown file shows its right neighbour, else the new last one. */
  const close = (path: string) => {
    const rest = open.filter((other) => other !== path);
    const next =
      path === file ? (rest[open.indexOf(path)] ?? rest.at(-1) ?? null) : file;
    setOpenFiles(rest);
    setParams({ file: next });
  };

  return { open, select, follow, close };
}
