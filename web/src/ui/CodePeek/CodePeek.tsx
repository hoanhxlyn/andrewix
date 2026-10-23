import {
  type CSSProperties,
  type MouseEvent,
  useCallback,
  useEffect,
  useMemo,
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
import * as s from "./CodePeek.css";

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

interface Token {
  readonly id: number;
  readonly content: string;
  readonly htmlStyle?: CSSProperties;
  /** Repository path of the file an aspect reference points to, or null for plain code. */
  readonly link: string | null;
}

interface Line {
  readonly id: number;
  /** Displayed line number, counting from 1. */
  readonly number: number;
  readonly tokens: readonly Token[];
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
  /** Repository path of the file to show, or null for the empty state. */
  path: string | null;
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
  const [message, setMessage] = useState<string | null>(
    "Pick a file in the tree.",
  );

  useEffect(() => {
    if (!path) {
      setLines(null);
      setMessage("Pick a file in the tree.");
      return;
    }
    if (!isTextFile(path)) {
      setLines(null);
      setMessage("Not a text file.");
      return;
    }
    let active = true;
    setLines(null);
    setMessage(null);
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
      if (active) setLines(withIds(rows));
    })().catch(() => {
      if (active) setMessage("Could not load this file.");
    });
    return () => {
      active = false;
    };
  }, [path]);

  // A plain click opens the file in place; modified and middle clicks follow the href as usual.
  // The latest callback is read at click time so the memoized source below stays valid.
  const latestOpen = useRef(onOpen);
  latestOpen.current = onOpen;
  const follow = useCallback((e: MouseEvent, path: string) => {
    if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey)
      return;
    e.preventDefault();
    latestOpen.current(path);
  }, []);

  // Built once per loaded file: the page re-renders on every URL change (tree toggle, wrap,
  // search), and recreating thousands of token spans each time made those changes stall.
  const source = useMemo(
    () =>
      lines?.map((line) => (
        <div key={line.id}>
          <span className={s.num} data-num>
            {line.number}
          </span>
          <span className={s.content}>
            {line.tokens.map(({ id, content, htmlStyle, link }) =>
              link === null ? (
                <span key={id} style={htmlStyle}>
                  {content}
                </span>
              ) : (
                <a
                  key={id}
                  className={s.link}
                  href={hrefOf(link)}
                  onClick={(e) => follow(e, link)}
                >
                  <span style={htmlStyle}>{content}</span>
                </a>
              ),
            )}
            {"\n"}
          </span>
        </div>
      )),
    [lines, hrefOf, follow],
  );

  return (
    <pre
      className={[s.code, wrap && s.wrapped, className]
        .filter(Boolean)
        .join(" ")}
    >
      {source ? (
        source
      ) : message === null ? (
        <div className={s.skeleton} role="status" aria-label="Loading">
          {SKELETON_LINES.map((id) => (
            <div key={id} className={s.skeletonLine} />
          ))}
        </div>
      ) : (
        <code className={s.message}>{message}</code>
      )}
    </pre>
  );
}
