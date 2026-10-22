import { type CSSProperties, useEffect, useState } from "react";
import {
  type BundledLanguage,
  createHighlighter,
  type Highlighter,
} from "shiki";
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

const THEMES = { light: "catppuccin-latte", dark: "catppuccin-mocha" };

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
  className?: string;
}

/** Shows the source of one repository file, highlighted for the current theme. */
export function CodePeek({ path, className }: CodePeekProps) {
  const [lines, setLines] = useState<Line[] | null>(null);
  const [message, setMessage] = useState("Pick a file in the tree.");

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
    const code = sourceOf(path);
    if (code === null) {
      setLines(null);
      setMessage("Not a file of the config.");
      return;
    }
    let active = true;
    setLines(null);
    setMessage("Loading…");
    void (async () => {
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

  return (
    <section className={[s.pane, className].filter(Boolean).join(" ")}>
      <p className={s.header}>{path ?? "Source"}</p>
      <pre className={s.code}>
        {lines ? (
          lines.map((line) => (
            <div key={line.id}>
              <span className={s.num} data-num>
                {line.number}
              </span>
              {line.tokens.map((token) => (
                <span key={token.id} style={token.htmlStyle}>
                  {token.content}
                </span>
              ))}
              {"\n"}
            </div>
          ))
        ) : (
          <code className={s.message}>{message}</code>
        )}
      </pre>
    </section>
  );
}
