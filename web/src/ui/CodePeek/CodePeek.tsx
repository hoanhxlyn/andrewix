import {
  type CSSProperties,
  type ReactNode,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  type BundledLanguage,
  createHighlighter,
  type Highlighter,
} from "shiki";
import { isTextFile, languageOf, sourceOf } from "@/helper/config-files";
import { Checkbox } from "@/ui/Checkbox";
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
    tokens: row.map((token) => ({ ...token, id: id++ })),
  }));
}

interface CodePeekProps {
  /** Repository path of the file to show, or null for the empty state. */
  path: string | null;
  /** Whether long lines wrap to the pane instead of scrolling sideways. */
  wrap: boolean;
  /** Called when the wrap checkbox is toggled. */
  onWrapChange: (wrap: boolean) => void;
  /** Controls placed before the path in the bar above the source. */
  start?: ReactNode;
  className?: string;
}

/** Shows the source of one repository file, highlighted for the current theme. */
export function CodePeek({
  path,
  wrap,
  onWrapChange,
  start,
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
            {line.tokens.map((token) => (
              <span key={token.id} style={token.htmlStyle}>
                {token.content}
              </span>
            ))}
            {"\n"}
          </span>
        </div>
      )),
    [lines],
  );

  return (
    <section className={[s.pane, className].filter(Boolean).join(" ")}>
      <div className={s.header}>
        {start}
        <p className={s.title}>{path ?? "Source"}</p>
        <Checkbox isSelected={wrap} onChange={onWrapChange}>
          wrap
        </Checkbox>
      </div>
      <pre className={wrap ? `${s.code} ${s.wrapped}` : s.code}>
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
    </section>
  );
}
