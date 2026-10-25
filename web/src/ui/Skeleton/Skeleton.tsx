import * as s from "./Skeleton.css";

/** Placeholder lines; the pane clips the ones that do not fit. */
const LINES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

interface SkeletonProps {
  className?: string;
  /** `image` is a single pulsing block for a picture; the default stands in for text. */
  variant?: "text" | "image";
}

/** Stands in for content while it loads. */
export function Skeleton({ className, variant = "text" }: SkeletonProps) {
  if (variant === "image") {
    // Hidden from assistive tech: a grid of these would announce itself once per picture.
    return (
      <div
        className={[s.skeleton, s.image, className].filter(Boolean).join(" ")}
        aria-hidden
      />
    );
  }

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
