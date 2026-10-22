import { type Dirent, readdirSync } from "node:fs";
import { basename, join, resolve } from "node:path";
import { filter, map, pipe, sortBy } from "remeda";
import type { Plugin } from "vite";
import type { FolderNode } from "@/ui/FolderTree";

type Node = FolderNode;
type Folder = Extract<Node, { kind: "folder" }>;

const VIRTUAL_ID = "virtual:repo-tree";
const RESOLVED_ID = `\0${VIRTUAL_ID}`;

/** Folders of the repository root that are scanned. */
const SCANNED = ["modules", "config"];

/** Folders first, then files, each by name. Hidden entries are skipped. */
function visibleEntries(path: string): Dirent[] {
  return pipe(
    readdirSync(path, { withFileTypes: true }),
    filter((entry) => !entry.name.startsWith(".")),
    sortBy(
      (entry) => (entry.isDirectory() ? 0 : 1),
      (entry) => entry.name,
    ),
  );
}

function folder(name: string, children: Node[]): Folder {
  return { kind: "folder", name, children };
}

function scan(path: string, name: string): Folder {
  return folder(
    name,
    pipe(
      visibleEntries(path),
      map(
        (entry): Node =>
          entry.isDirectory()
            ? scan(join(path, entry.name), entry.name)
            : { kind: "file", name: entry.name },
      ),
    ),
  );
}

/**
 * Scans `../modules` and `../config` at build time and exposes them as a folder tree through
 * the `virtual:repo-tree` module. The dev server reloads when files there are added or removed.
 */
export function repoTree(): Plugin {
  let root = "";

  return {
    name: "repo-tree",
    configResolved(config) {
      root = resolve(config.root, "..");
    },
    resolveId(id) {
      return id === VIRTUAL_ID ? RESOLVED_ID : null;
    },
    load(id) {
      if (id !== RESOLVED_ID) return null;
      const tree = folder(
        basename(root),
        SCANNED.map((name) => scan(join(root, name), name)),
      );
      return `export default ${JSON.stringify(tree)}`;
    },
    configureServer(server) {
      const folders = SCANNED.map((name) => join(root, name));
      server.watcher.add(folders);
      const reload = (file: string) => {
        if (!folders.some((path) => file.startsWith(path))) return;
        const module = server.moduleGraph.getModuleById(RESOLVED_ID);
        if (module) server.moduleGraph.invalidateModule(module);
        server.ws.send({ type: "full-reload" });
      };
      server.watcher.on("add", reload).on("unlink", reload);
    },
  };
}
