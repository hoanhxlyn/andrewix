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

/**
 * Pill label of an open file: the shortest end of its path that no other open file ends with, so
 * two tabs never read the same.
 */
export function labelOf(path: string, open: readonly string[]): string {
  const parts = path.split("/");
  const others = open.filter((other) => other !== path);
  for (let count = 1; count < parts.length; count++) {
    const end = parts.slice(-count).join("/");
    const shared = others.some(
      (other) => other === end || other.endsWith(`/${end}`),
    );
    if (!shared) return end;
  }
  return path;
}
