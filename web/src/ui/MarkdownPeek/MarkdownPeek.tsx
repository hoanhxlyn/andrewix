import rehypeShikiFromHighlighter from "@shikijs/rehype/core";
import { clsx } from "clsx";
import { useEffect, useState } from "react";
import Markdown, { type Components } from "react-markdown";
import remarkGfm from "remark-gfm";
import type { Highlighter } from "shiki";
import { sourceOf } from "@/helper/config-files";
import { highlighter, THEMES } from "@/helper/highlighter";
import { EmptyState } from "@/ui/EmptyState";
import Icons from "@/ui/Icon";
import { Skeleton } from "@/ui/Skeleton";
import * as s from "./MarkdownPeek.css";

/** A loaded file with the highlighter for its code blocks, or why it could not be loaded. */
type Result =
  | { path: string; source: string; highlighter: Highlighter }
  | { path: string; problem: "missing" | "failed" };

/** Links leave the app in a new tab; anchors within the document stay in place. */
const components: Components = {
  a: ({ node: _, ...props }) =>
    props.href?.startsWith("#") ? (
      <a {...props} />
    ) : (
      <a {...props} target="_blank" rel="noreferrer" />
    ),
};

interface MarkdownPeekProps {
  /** Repository path of the markdown file to show. */
  path: string;
  className?: string;
}

/** Shows one repository markdown file rendered, with its code blocks highlighted. */
export function MarkdownPeek({ path, className }: MarkdownPeekProps) {
  const [result, setResult] = useState<Result | null>(null);

  useEffect(() => {
    let active = true;
    Promise.all([sourceOf(path), highlighter()]).then(
      ([source, shared]) => {
        if (!active) return;
        setResult(
          source === null
            ? { path, problem: "missing" }
            : { path, source, highlighter: shared },
        );
      },
      () => {
        if (active) setResult({ path, problem: "failed" });
      },
    );
    return () => {
      active = false;
    };
  }, [path]);

  // A result of the previous file is not shown while the next one loads.
  const current = result?.path === path ? result : null;
  const frameClass = clsx(s.frame, className);

  if (current === null) {
    return <Skeleton className={className} />;
  }
  if ("problem" in current) {
    return current.problem === "missing" ? (
      <EmptyState icon={<Icons.UnknownFile />} className={className}>
        Not a file of the config.
      </EmptyState>
    ) : (
      <EmptyState icon={<Icons.Alert />} className={className}>
        Could not load this file.
      </EmptyState>
    );
  }

  return (
    <div className={frameClass}>
      <div className={s.prose}>
        <Markdown
          remarkPlugins={[remarkGfm]}
          rehypePlugins={[
            [
              rehypeShikiFromHighlighter,
              current.highlighter,
              // Code blocks in a language without a loaded grammar show as plain text.
              { themes: THEMES, fallbackLanguage: "text" },
            ],
          ]}
          components={components}
        >
          {current.source}
        </Markdown>
      </div>
    </div>
  );
}
