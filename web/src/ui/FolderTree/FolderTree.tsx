import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  type Key,
  Tree,
  TreeItem,
  TreeItemContent,
} from "react-aria-components/Tree";
import { Button } from "@/ui/Button";
import Icons from "@/ui/Icon";
import * as s from "./FolderTree.css";

/** A file, or a folder with its children. */
export type FolderNode =
  | { readonly kind: "file"; readonly name: string }
  | {
      readonly kind: "folder";
      readonly name: string;
      readonly children: readonly FolderNode[];
    };

/** File icons per extension, falling back to the generic file icon. */
const FILE_ICONS: Record<string, typeof Icons.File> = {
  json: Icons.JsonFile,
  lua: Icons.LuaFile,
  md: Icons.MarkdownFile,
  nix: Icons.NixFile,
  sh: Icons.ShellFile,
  toml: Icons.TomlFile,
  yaml: Icons.YamlFile,
  yml: Icons.YamlFile,
};

/** File icon of a name: its extension's icon, or the generic file icon. */
function TypeIcon({ name }: { readonly name: string }) {
  const dot = name.lastIndexOf(".");
  const ext = dot === -1 ? "" : name.slice(dot + 1).toLowerCase();
  const Icon = FILE_ICONS[ext] ?? Icons.File;
  return <Icon aria-hidden />;
}

/** Repository path of a child node. */
function childPath(path: string, name: string): string {
  return path === "" ? name : `${path}/${name}`;
}

/** Whether the node or any descendant matches the query against its repository path. */
function matches(node: FolderNode, path: string, query: string): boolean {
  if (node.kind === "file") return path.toLowerCase().includes(query);
  return node.children.some((child) =>
    matches(child, childPath(path, child.name), query),
  );
}

/** Paths of every file in the tree. */
function filePaths(node: FolderNode, path: string): string[] {
  if (node.kind === "file") return [path];
  return node.children.flatMap((child) =>
    filePaths(child, childPath(path, child.name)),
  );
}

/** Folder paths that must stay open to show the given file paths. */
function ancestorsOf(paths: Iterable<string>): Set<string> {
  const out = new Set<string>();
  for (const path of paths) {
    const parts = path.split("/");
    for (let i = 1; i < parts.length; i += 1)
      out.add(parts.slice(0, i).join("/"));
  }
  return out;
}

/** The set with one key toggled in or out. */
function toggled(set: Set<Key>, key: Key): Set<Key> {
  const next = new Set(set);
  if (next.has(key)) next.delete(key);
  else next.add(key);
  return next;
}

interface BranchProps {
  node: FolderNode;
  path: string;
  filter: string;
  onSelect: (path: string) => void;
}

/** One file or folder of the tree. Nested items render as flattened rows. */
function Branch({ node, path, filter, onSelect }: BranchProps) {
  if (node.kind === "file") {
    return (
      <TreeItem
        id={path}
        className={s.item}
        textValue={node.name}
        onAction={() => onSelect(path)}
      >
        <TreeItemContent>
          {({ isHovered, isPressed, isFocusVisible, isSelected }) => (
            <span
              className={s.row}
              data-hovered={isHovered || undefined}
              data-pressed={isPressed || undefined}
              data-focus-visible={isFocusVisible || undefined}
              data-selected={isSelected || undefined}
            >
              <span className={s.spacer} />
              <TypeIcon name={node.name} />
              {node.name}
            </span>
          )}
        </TreeItemContent>
      </TreeItem>
    );
  }

  const children = filter
    ? node.children.filter((child) =>
        matches(child, childPath(path, child.name), filter),
      )
    : node.children;

  return (
    <TreeItem
      id={path}
      className={s.item}
      textValue={`${node.name}/`}
      hasChildItems
    >
      <TreeItemContent>
        {({ isExpanded, isHovered, isPressed, isFocusVisible, isSelected }) => (
          <span
            className={s.row}
            data-hovered={isHovered || undefined}
            data-pressed={isPressed || undefined}
            data-focus-visible={isFocusVisible || undefined}
            data-selected={isSelected || undefined}
          >
            <Button
              slot="chevron"
              variant="icon"
              icon={
                <Icons.Chevron
                  className={isExpanded ? s.chevronOpen : undefined}
                />
              }
              aria-label={
                isExpanded ? `Collapse ${node.name}` : `Expand ${node.name}`
              }
            />
            {isExpanded ? <Icons.FolderOpen /> : <Icons.Folder />}
            {node.name}/
          </span>
        )}
      </TreeItemContent>
      {children.map((child) => (
        <Branch
          key={child.name}
          node={child}
          path={childPath(path, child.name)}
          filter={filter}
          onSelect={onSelect}
        />
      ))}
    </TreeItem>
  );
}

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
  const [opened, setOpened] = useState<Set<Key>>(() => new Set());
  const files = new Set(filePaths(tree, ""));
  // Branches only re-render when the filter or tree change, not on every keystroke in the field:
  // a stable callback and memoized elements let React skip the hundreds of unchanged rows.
  const latestSelect = useRef(onSelect);
  latestSelect.current = onSelect;
  const select = useCallback((path: string) => latestSelect.current(path), []);
  const items = useMemo(
    () =>
      tree.children
        .filter((child) => filter === "" || matches(child, child.name, filter))
        .map((child) => (
          <Branch
            key={child.name}
            node={child}
            path={child.name}
            filter={filter}
            onSelect={select}
          />
        )),
    [tree, filter, select],
  );
  // Arrow-key navigation also moves the selection; it must not open files, only presses and Enter.
  // The flag is set in the capture phase: the tree changes the selection while handling the same
  // keydown, before a bubbling handler on this wrapper would run.
  const keyboardNav = useRef(false);
  // Selecting a file opens its folders once; they can be closed again afterwards.
  useEffect(() => {
    if (selected === null) return;
    setOpened((prev) => new Set([...prev, ...ancestorsOf([selected])]));
  }, [selected]);
  // A search opens the folders of its matches once; they can be closed again afterwards.
  useEffect(() => {
    if (filter === "") return;
    const hits = filePaths(tree, "").filter((path) =>
      path.toLowerCase().includes(filter),
    );
    setOpened((prev) => new Set([...prev, ...ancestorsOf(hits)]));
  }, [filter, tree]);

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
        {items}
      </Tree>
    </div>
  );
}
