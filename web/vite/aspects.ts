import { readdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import type { Plugin } from "vite";

const VIRTUAL_ID = "virtual:aspects";
const RESOLVED_ID = `\0${VIRTUAL_ID}`;

/** Folder of the repository root whose Nix files define the aspects. */
const SCANNED = "modules";

/** Keys inside an aspect that configure it rather than name a nested aspect. */
const KEYWORDS = new Set([
  "includes",
  "nixos",
  "homeManager",
  "provides",
  "darwin",
  "description",
  "user",
  "os",
]);

/** `core.x.y = ` or `den.aspects.x = ` at the top level of a module's attrset. */
const TOP = /^ {2}((?:core|den\.aspects)(?:\.[\w-]+)*)\s*=/;

/** `name = ` one level inside a top-level key, as in `core.x = { name = ...; }`. */
const INNER = /^ {4}([\w-]+)\s*=/;

/** Aspect names a module defines, from its alejandra-formatted source. */
function definedIn(source: string): string[] {
  const names: string[] = [];
  let block = "";
  for (const line of source.split("\n")) {
    const top = line.match(TOP)?.[1];
    const inner = line.match(INNER)?.[1];
    if (top) block = top;
    else if (!line.startsWith("    ")) block = "";
    const key = top ?? (inner && block ? `${block}.${inner}` : null);
    if (!key || key === "core" || key === "den.aspects") continue;
    const parts = key.replace(/^den\.aspects\./, "").split(".");
    const cut = parts.findIndex((part, i) => i > 0 && KEYWORDS.has(part));
    names.push((cut === -1 ? parts : parts.slice(0, cut)).join("."));
  }
  return names;
}

/** Repository path of the file defining each aspect; the first definition wins. */
function scan(root: string): Record<string, string> {
  const aspects: Record<string, string> = {};
  const files = readdirSync(join(root, SCANNED), { recursive: true })
    .map(String)
    .filter((file) => file.endsWith(".nix"))
    .sort();
  for (const file of files) {
    const path = `${SCANNED}/${file}`;
    for (const name of definedIn(readFileSync(join(root, path), "utf8")))
      aspects[name] ??= path;
  }
  return aspects;
}

/**
 * Finds the den aspects defined under `../modules` at build time and exposes, through the
 * `virtual:aspects` module, the file that defines each one, so `<core.x>` references can link to
 * it. The names are read from the source text, not evaluated. The dev server reloads when a module
 * changes.
 */
export function aspects(): Plugin {
  let root = "";

  return {
    name: "aspects",
    configResolved(config) {
      root = resolve(config.root, "..");
    },
    resolveId(id) {
      return id === VIRTUAL_ID ? RESOLVED_ID : null;
    },
    load(id) {
      if (id !== RESOLVED_ID) return null;
      return `export const aspects = ${JSON.stringify(scan(root))};`;
    },
    configureServer(server) {
      const folder = join(root, SCANNED);
      server.watcher.add(folder);
      const reload = (file: string) => {
        if (!file.startsWith(folder) || !file.endsWith(".nix")) return;
        const module = server.moduleGraph.getModuleById(RESOLVED_ID);
        if (module) server.moduleGraph.invalidateModule(module);
        server.ws.send({ type: "full-reload" });
      };
      server.watcher
        .on("add", reload)
        .on("unlink", reload)
        .on("change", reload);
    },
  };
}
