import {
  type ComponentProps,
  type CSSProperties,
  type MouseEvent,
  useCallback,
  useEffect,
  useRef,
  useState,
} from "react";
import type { BundledLanguage } from "shiki";
import { aspectPath } from "@/helper/aspects";
import { isTextFile, languageOf, sourceOf } from "@/helper/config-files";
import { highlighter, THEMES } from "@/helper/highlighter";
import { EmptyState } from "@/ui/EmptyState";
import Icons from "@/ui/Icon";
import { Skeleton } from "@/ui/Skeleton";
import * as s from "./CodePeek.css";
import { type Line, Source } from "./Source";

/** Shortest time the skeleton shows, so a fast load does not flash. */
const MIN_LOADING_MS = 1000;

/** Lines of every file shown before, so switching back to one shows it at once. */
const loaded = new Map<string, Line[]>();

/** Why a file cannot be shown, with the icon its empty state carries. */
interface Problem {
  icon: ComponentProps<typeof EmptyState>["icon"];
  text: string;
}

const NOT_TEXT: Problem = {
  icon: <Icons.UnsupportedFile />,
  text: "Cannot preview this file.",
};
const NOT_IN_CONFIG: Problem = {
  icon: <Icons.UnknownFile />,
  text: "Not a file of the config.",
};
const LOAD_FAILED: Problem = {
  icon: <Icons.Alert />,
  text: "Could not load this file.",
};

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
  const [problem, setProblem] = useState<Problem | null>(null);

  useEffect(() => {
    if (!isTextFile(path)) {
      setLines(null);
      setProblem(NOT_TEXT);
      return;
    }
    setProblem(null);
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
        if (active) setProblem(NOT_IN_CONFIG);
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
      if (active) setProblem(LOAD_FAILED);
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

  if (problem !== null) {
    return (
      <EmptyState icon={problem.icon} className={className}>
        {problem.text}
      </EmptyState>
    );
  }

  if (lines === null) {
    return <Skeleton className={className} />;
  }

  return (
    <pre
      className={[s.code, wrap && s.wrapped, className]
        .filter(Boolean)
        .join(" ")}
    >
      <Source lines={lines} hrefOf={hrefOf} onFollow={follow} />
    </pre>
  );
}
