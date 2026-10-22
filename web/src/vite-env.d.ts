/// <reference types="vite/client" />
/// <reference types="unplugin-fonts/client" />
/// <reference types="ondine/vite/client" />

declare module "virtual:repo-tree" {
  import type { FolderNode } from "@/ui/FolderTree";

  /** The `modules` and `config` folders of the repository as a folder tree. */
  const tree: Extract<FolderNode, { kind: "folder" }>;
  export default tree;
}
