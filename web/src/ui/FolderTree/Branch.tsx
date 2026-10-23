import { memo } from "react";
import {
  type Key,
  TreeItem,
  TreeItemContent,
} from "react-aria-components/Tree";
import { Button } from "@/ui/Button";
import Icons from "@/ui/Icon";
import type { FolderNode } from "./FolderTree";
import * as s from "./FolderTree.css";
import { Name } from "./Name";
import { childPath, matches } from "./tree-paths";

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

interface BranchProps {
  node: FolderNode;
  path: string;
  filter: string;
  /** Paths of the open folders; only their children are rendered. */
  opened: ReadonlySet<Key>;
  onSelect: (path: string) => void;
}

/**
 * One file or folder of the tree. Nested items render as flattened rows. Memoized, so a row only
 * re-renders when its own props change, not on every keystroke in the search.
 */
export const Branch = memo(function Branch({
  node,
  path,
  filter,
  opened,
  onSelect,
}: BranchProps) {
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
              <Name text={node.name} isActive={isHovered || isFocusVisible} />
            </span>
          )}
        </TreeItemContent>
      </TreeItem>
    );
  }

  // A closed folder renders no children: the tree builds its collection from every rendered
  // item, so rendering the whole repository made opening and filtering the tree slow.
  // `hasChildItems` still gives it a chevron.
  const children = !opened.has(path)
    ? []
    : filter
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
            <Name
              text={`${node.name}/`}
              isActive={isHovered || isFocusVisible}
            />
          </span>
        )}
      </TreeItemContent>
      {children.map((child) => (
        <Branch
          key={child.name}
          node={child}
          path={childPath(path, child.name)}
          filter={filter}
          opened={opened}
          onSelect={onSelect}
        />
      ))}
    </TreeItem>
  );
});
