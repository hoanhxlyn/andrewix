import { type CSSProperties, type MouseEvent, memo } from "react";
import * as s from "./CodePeek.css";

interface Token {
  readonly id: number;
  readonly content: string;
  readonly htmlStyle?: CSSProperties;
  /** Repository path of the file an aspect reference points to, or null for plain code. */
  readonly link: string | null;
}

export interface Line {
  readonly id: number;
  /** Displayed line number, counting from 1. */
  readonly number: number;
  readonly tokens: readonly Token[];
}

interface SourceProps {
  lines: readonly Line[];
  /** URL of a linked file, for opening it in a new tab. */
  hrefOf: (path: string) => string;
  /** Called when a link is clicked, with the repository path it points to. */
  onFollow: (e: MouseEvent, path: string) => void;
}

/**
 * Numbered, highlighted lines of one file. Memoized, so it renders once per loaded file: the page
 * re-renders on every change of its state (tree toggle, wrap, search), and recreating thousands of
 * token spans each time made those changes stall.
 */
export const Source = memo(function Source({
  lines,
  hrefOf,
  onFollow,
}: SourceProps) {
  return lines.map((line) => (
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
              onClick={(e) => onFollow(e, link)}
            >
              <span style={htmlStyle}>{content}</span>
            </a>
          ),
        )}
        {"\n"}
      </span>
    </div>
  ));
});
