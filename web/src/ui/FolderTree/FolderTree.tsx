import { useEffect, useRef, useState } from "react";
import {
  type Key,
  Tree,
  TreeItem,
  TreeItemContent,
} from "react-aria-components/Tree";
import { Button } from "@/ui/Button";
import BashIcon from "~icons/mdi/bash";
import ChevronIcon from "~icons/mdi/chevron-right";
import BracesIcon from "~icons/mdi/code-braces";
import BracketsIcon from "~icons/mdi/code-brackets";
import JsonIcon from "~icons/mdi/code-json";
import GenericIcon from "~icons/mdi/file-outline";
import ClosedIcon from "~icons/mdi/folder";
import OpenIcon from "~icons/mdi/folder-open";
import LuaIcon from "~icons/mdi/language-lua";
import MarkdownIcon from "~icons/mdi/language-markdown";
import NixIcon from "~icons/mdi/snowflake";
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
const FILE_ICONS: Record<string, typeof GenericIcon> = {
  json: JsonIcon,
  lua: LuaIcon,
  md: MarkdownIcon,
  nix: NixIcon,
  sh: BashIcon,
  toml: BracketsIcon,
  yaml: BracesIcon,
  yml: BracesIcon,
};

/** File icon of a name: its extension's icon, or the generic file icon. */
function TypeIcon({ name }: { readonly name: string }) {
  const dot = name.lastIndexOf(".");
  const ext = dot === -1 ? "" : name.slice(dot + 1).toLowerCase();
  const Icon = FILE_ICONS[ext] ?? GenericIcon;
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
      <TreeItem id={path} textValue={node.name} onAction={() => onSelect(path)}>
        <TreeItemContent>
          <span className={s.row}>
            <span className={s.spacer} />
            <TypeIcon name={node.name} />
            {node.name}
          </span>
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
    <TreeItem id={path} textValue={`${node.name}/`} hasChildItems>
      <TreeItemContent>
        {({ isExpanded }) => (
          <span className={s.row}>
            <Button
              slot="chevron"
              variant="icon"
              icon={
                <ChevronIcon
                  className={isExpanded ? s.chevronOpen : undefined}
                />
              }
              aria-label={
                isExpanded ? `Collapse ${node.name}` : `Expand ${node.name}`
              }
            />
            {isExpanded ? <OpenIcon /> : <ClosedIcon />}
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
  // Arrow-key navigation also moves the selection; it must not open files, only presses and Enter.
  const keyboardNav = useRef(false);
  // Selecting a file opens its folders once; they can be closed again afterwards.
  useEffect(() => {
    if (selected === null) return;
    setOpened((prev) => new Set([...prev, ...ancestorsOf([selected])]));
  }, [selected]);

  return (
    // biome-ignore lint/a11y/noStaticElementInteractions: React Aria's Tree takes no keyboard props; pure event glue for the rows
    <div
      onKeyDown={(e) => {
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
              onSelect={onSelect}
            />
          ))}
      </Tree>
    </div>
  );
}
