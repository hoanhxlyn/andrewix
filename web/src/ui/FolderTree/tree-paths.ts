import type { Key } from "react-aria-components/Tree";
import type { FolderNode } from "./FolderTree";

/** Repository path of a child node. */
export function childPath(path: string, name: string): string {
  return path === "" ? name : `${path}/${name}`;
}

/** Whether the node or any descendant matches the query against its repository path. */
export function matches(
  node: FolderNode,
  path: string,
  query: string,
): boolean {
  if (node.kind === "file") return path.toLowerCase().includes(query);
  return node.children.some((child) =>
    matches(child, childPath(path, child.name), query),
  );
}

/** Paths of every file in the tree. */
export function filePaths(node: FolderNode, path: string): string[] {
  if (node.kind === "file") return [path];
  return node.children.flatMap((child) =>
    filePaths(child, childPath(path, child.name)),
  );
}

/** Folder paths that must stay open to show the given file paths. */
export function ancestorsOf(paths: Iterable<string>): Set<string> {
  const out = new Set<string>();
  for (const path of paths) {
    const parts = path.split("/");
    for (let i = 1; i < parts.length; i += 1)
      out.add(parts.slice(0, i).join("/"));
  }
  return out;
}

/** The set with one key toggled in or out. */
export function toggled(set: Set<Key>, key: Key): Set<Key> {
  const next = new Set(set);
  if (next.has(key)) next.delete(key);
  else next.add(key);
  return next;
}
