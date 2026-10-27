/// <reference types="vite/client" />
/// <reference types="unplugin-fonts/client" />

declare module "virtual:repo-tree" {
  import type { FolderNode } from "@/ui";

  /** The `modules` and `config` folders of the repository as a folder tree. */
  export const tree: Extract<FolderNode, { kind: "folder" }>;
}

declare module "virtual:aspects" {
  /** Repository path of the file defining each den aspect, keyed by its dotted name. */
  export const aspects: Readonly<Record<string, string>>;
}
