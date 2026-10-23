import autoAnimate from "@formkit/auto-animate";
import { useAtom } from "jotai";
import { useCallback, useEffect, useRef } from "react";
import { Tree } from "react-aria-components/Tree";
import { openedFoldersAtom } from "@/atoms/folder-tree";
import { motion } from "@/styles/tokens.css";
import { Branch } from "./Branch";
import * as s from "./FolderTree.css";
import { ancestorsOf, filePaths, matches, toggled } from "./tree-paths";

/** A file, or a folder with its children. */
export type FolderNode =
  | { readonly kind: "file"; readonly name: string }
  | {
      readonly kind: "folder";
      readonly name: string;
      readonly children: readonly FolderNode[];
    };

interface FolderTreeProps {
  tree: Extract<FolderNode, { kind: "folder" }>;
  /** Repository path of the file to highlight, or null. */
  selected: string | null;
  /** Case-insensitive path fragment to filter by; empty shows everything. */
  query: string;
  /** Called with the repository path of a file when it is pressed. */
  onSelect: (path: string) => void;
}

/** A tree of the repository's folders and files, filterable and single-select. */
export function FolderTree({
  tree,
  selected,
  query,
  onSelect,
}: FolderTreeProps) {
  const filter = query.trim().toLowerCase();
  const [opened, setOpened] = useAtom(openedFoldersAtom);
  const files = new Set(filePaths(tree, ""));
  // Branches only re-render when the filter, open folders or tree change, not on every keystroke:
  // a stable callback lets the memoized rows skip the hundreds that did not change.
  const latestSelect = useRef(onSelect);
  latestSelect.current = onSelect;
  const select = useCallback((path: string) => latestSelect.current(path), []);
  // Arrow-key navigation also moves the selection; it must not open files, only presses and Enter.
  // The flag is set in the capture phase: the tree changes the selection while handling the same
  // keydown, before a bubbling handler on this wrapper would run.
  const keyboardNav = useRef(false);
  // Rows fade in and out as folders open and close, and the rows below slide into place. React
  // Aria drops a closed folder's rows at once, so the leaving rows are animated from the DOM.
  // Not `useAutoAnimate`: Strict Mode attaches the ref twice and the hook never disconnects the
  // first observer, whose second pass cancels every fade-in. A ref cleanup tears each one down.
  const animated = useCallback((node: HTMLDivElement) => {
    const controller = autoAnimate(node, {
      duration: motion.duration,
      easing: motion.easing,
    });
    return () => controller.destroy?.();
  }, []);
  // Selecting a file opens its folders once; they can be closed again afterwards.
  useEffect(() => {
    if (selected === null) return;
    setOpened((prev) => new Set([...prev, ...ancestorsOf([selected])]));
  }, [selected, setOpened]);
  // A search opens the folders of its matches once; they can be closed again afterwards.
  useEffect(() => {
    if (filter === "") return;
    const hits = filePaths(tree, "").filter((path) =>
      path.toLowerCase().includes(filter),
    );
    setOpened((prev) => new Set([...prev, ...ancestorsOf(hits)]));
  }, [filter, tree, setOpened]);

  return (
    <div
      onKeyDownCapture={(e) => {
        keyboardNav.current = /^(Arrow|Home|End)/.test(e.key);
      }}
      onPointerDown={() => {
        keyboardNav.current = false;
      }}
    >
      <Tree
        ref={animated}
        aria-label="Config files"
        className={s.tree}
        selectionMode="single"
        selectionBehavior="replace"
        selectedKeys={selected === null ? new Set() : new Set([selected])}
        onSelectionChange={(keys) => {
          if (keys === "all") return;
          const fromKeyboardNav = keyboardNav.current;
          keyboardNav.current = false;
          if (fromKeyboardNav) return;
          for (const key of keys) {
            const id = String(key);
            if (files.has(id)) onSelect(id);
            // Folder presses never stick (the selection is the file), so they fire on every click.
            else setOpened((prev) => toggled(prev, key));
          }
        }}
        expandedKeys={opened}
        onExpandedChange={setOpened}
        renderEmptyState={() => <p className={s.empty}>No files matched.</p>}
      >
        {tree.children
          .filter(
            (child) => filter === "" || matches(child, child.name, filter),
          )
          .map((child) => (
            <Branch
              key={child.name}
              node={child}
              path={child.name}
              filter={filter}
              opened={opened}
              onSelect={select}
            />
          ))}
      </Tree>
    </div>
  );
}
