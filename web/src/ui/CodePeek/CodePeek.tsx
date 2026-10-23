import {
  type CSSProperties,
  type MouseEvent,
  useCallback,
  useEffect,
  useRef,
  useState,
} from "react";
import {
  type BundledLanguage,
  createHighlighter,
  type Highlighter,
} from "shiki";
import { aspectPath } from "@/helper/aspects";
import { isTextFile, languageOf, sourceOf } from "@/helper/config-files";
import { EmptyState } from "@/ui/EmptyState";
import * as s from "./CodePeek.css";
import { type Line, Source } from "./Source";

/** Grammars the pane can highlight. Shiki builds them once on first use. */
const LANGS = [
  "nix",
  "lua",
  "json",
  "toml",
  "yaml",
  "bash",
  "markdown",
] as const;

/** Shortest time the skeleton shows, so a fast load does not flash. */
const MIN_LOADING_MS = 1000;

/** Lines of every file shown before, so switching back to one shows it at once. */
const loaded = new Map<string, Line[]>();

const THEMES = { light: "catppuccin-latte", dark: "catppuccin-mocha" };

/** Placeholder rows of the loading skeleton. */
const SKELETON_LINES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

let shared: Promise<Highlighter> | null = null;

function highlighter(): Promise<Highlighter> {
  shared ??= createHighlighter({
    themes: [THEMES.light, THEMES.dark],
    langs: [...LANGS],
  });
  return shared;
}

/** Numbers tokens and lines once per file, so the render needs no index keys. */
function withIds(
  rows: ReadonlyArray<
    ReadonlyArray<{ content: string; htmlStyle?: CSSProperties }>
  >,
): Line[] {
  let id = 0;
  let number = 0;
  return rows.map((row) => ({
    id: id++,
    number: ++number,
    tokens: row.map((token) => ({
      ...token,
      id: id++,
      link: aspectPath(token.content),
    })),
  }));
}

interface CodePeekProps {
  /** Repository path of the file to show. */
  path: string;
  /** Whether long lines wrap to the pane instead of scrolling sideways. */
  wrap: boolean;
  /** URL of a linked file, for opening it in a new tab. */
  hrefOf: (path: string) => string;
  /** Called with the repository path of a linked file when its link is clicked. */
  onOpen: (path: string) => void;
  className?: string;
}

/** Shows the source of one repository file, highlighted for the current theme. */
export function CodePeek({
  path,
  wrap,
  hrefOf,
  onOpen,
  className,
}: CodePeekProps) {
  const [lines, setLines] = useState<Line[] | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!isTextFile(path)) {
      setLines(null);
      setMessage("Not a text file.");
      return;
    }
    setMessage(null);
    const known = loaded.get(path);
    if (known) {
      setLines(known);
      return;
    }
    let active = true;
    setLines(null);
    void (async () => {
      const [code] = await Promise.all([
        sourceOf(path),
        new Promise((done) => setTimeout(done, MIN_LOADING_MS)),
      ]);
      if (code === null) {
        if (active) setMessage("Not a file of the config.");
        return;
      }
      const lang = languageOf(path);
      const rows = lang
        ? (await highlighter()).codeToTokens(code, {
            lang: lang as BundledLanguage,
            themes: THEMES,
          }).tokens
        : code.split("\n").map((row) => [{ content: row }]);
      const numbered = withIds(rows);
      loaded.set(path, numbered);
      if (active) setLines(numbered);
    })().catch(() => {
      if (active) setMessage("Could not load this file.");
    });
    return () => {
      active = false;
    };
  }, [path]);

  // A plain click opens the file in place; modified and middle clicks follow the href as usual.
  // The latest callback is read at click time so the memoized source stays valid.
  const latestOpen = useRef(onOpen);
  latestOpen.current = onOpen;
  const follow = useCallback((e: MouseEvent, path: string) => {
    if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey)
      return;
    e.preventDefault();
    latestOpen.current(path);
  }, []);

  if (message !== null) {
    return <EmptyState className={className}>{message}</EmptyState>;
  }

  return (
    <pre
      className={[s.code, wrap && s.wrapped, className]
        .filter(Boolean)
        .join(" ")}
    >
      {lines ? (
        <Source lines={lines} hrefOf={hrefOf} onFollow={follow} />
      ) : (
        <div className={s.skeleton} role="status" aria-label="Loading">
          {SKELETON_LINES.map((id) => (
            <div key={id} className={s.skeletonLine} />
          ))}
        </div>
      )}
    </pre>
  );
}
