import { aspects } from "virtual:aspects";

/** An angle-bracket reference as shiki tokenizes it: `<core.x>`, `<core/x>` or `<workstation>`. */
const REF = /^<([\w./-]+)>$/;

/**
 * Repository path of the file defining the aspect a source token refers to, or null when the
 * token is no reference or names an aspect outside the repository (den's own batteries).
 */
export function aspectPath(token: string): string | null {
  const name = token.match(REF)?.[1]?.replaceAll("/", ".");
  return (name && aspects[name]) ?? null;
}
