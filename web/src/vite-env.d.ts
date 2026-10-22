/// <reference types="vite/client" />
/// <reference types="unplugin-fonts/client" />

declare module "virtual:repo-tree" {
  import type { FolderNode } from "@/ui/FolderTree";

  /** The `modules` and `config` folders of the repository as a folder tree. */
  export const tree: Extract<FolderNode, { kind: "folder" }>;

  /** Raw text of every text file of the config, keyed by repository path like `modules/hosts.nix`. */
  export const sources: Record<string, string>;
}
