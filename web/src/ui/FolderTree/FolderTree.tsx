import { useState } from "react";
import { Button } from "@/ui/Button";
import * as s from "./FolderTree.css";

/** A file, or a folder with its children. */
export type FolderNode =
  | { readonly kind: "file"; readonly name: string }
  | {
      readonly kind: "folder";
      readonly name: string;
      readonly children: readonly FolderNode[];
    };

interface FolderTreeProps {
  tree: FolderNode;
  /** Called with the repository path of a file when it is pressed. */
  onSelect: (path: string) => void;
}

interface BranchProps {
  node: FolderNode;
  /** Path of this node from the scanned root; empty for the root itself. */
  path: string;
  onSelect: (path: string) => void;
  /** The single root node: open by default and filled instead of tonal. */
  root?: boolean;
}

function Branch({ node, path, onSelect, root = false }: BranchProps) {
  const [open, setOpen] = useState(root);

  if (node.kind === "file") {
    return (
      <li className={s.item}>
        <Button variant="text" onPress={() => onSelect(path)}>
          {node.name}
        </Button>
      </li>
    );
  }

  return (
    <li className={s.item}>
      <Button
        variant={root ? "filled" : "tonal"}
        aria-expanded={open}
        onPress={() => setOpen(!open)}
      >
        {node.name}/
      </Button>
      {open && (
        <ul className={s.list}>
          {node.children.map((child) => (
            <Branch
              key={child.name}
              node={child}
              path={path ? `${path}/${child.name}` : child.name}
              onSelect={onSelect}
            />
          ))}
        </ul>
      )}
    </li>
  );
}

/** A left-to-right tree of folders and files. Folders open and close on press. */
export function FolderTree({ tree, onSelect }: FolderTreeProps) {
  return (
    <ul className={s.tree}>
      <Branch node={tree} path="" onSelect={onSelect} root />
    </ul>
  );
}
