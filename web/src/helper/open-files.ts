const nameOf = (path: string) => path.slice(path.lastIndexOf("/") + 1);

/**
 * The files to show as tabs: the stored ones, then the one in the link. Stored tabs or a link may
 * repeat a file or name one the repository no longer has; tabs need unique, existing paths.
 */
export function openPaths(
  stored: readonly string[],
  file: string | null,
  exists: (path: string) => boolean,
): string[] {
  return [...new Set([...stored, ...(file === null ? [] : [file])])].filter(
    exists,
  );
}

/** The file to show after closing a tab: its right neighbour, else the new last one, else none. */
export function shownAfterClose(
  open: readonly string[],
  path: string,
  shown: string | null,
): string | null {
  if (path !== shown) return shown;
  const rest = open.filter((other) => other !== path);
  return rest[open.indexOf(path)] ?? rest.at(-1) ?? null;
}

/** Pill label of an open file: its name, with its folder when another open file shares the name. */
export function labelOf(path: string, open: readonly string[]): string {
  const name = nameOf(path);
  const shared = open.filter((other) => nameOf(other) === name).length > 1;
  return shared ? path.split("/").slice(-2).join("/") : name;
}
