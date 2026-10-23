import * as s from "./Skeleton.css";

/** Placeholder lines; the pane clips the ones that do not fit. */
const LINES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

interface SkeletonProps {
  className?: string;
}

/** Stands in for a pane's content while it loads. */
export function Skeleton({ className }: SkeletonProps) {
  return (
    <div
      className={[s.skeleton, className].filter(Boolean).join(" ")}
      role="status"
      aria-label="Loading"
    >
      {LINES.map((id) => (
        <div key={id} className={s.line} />
      ))}
    </div>
  );
}
