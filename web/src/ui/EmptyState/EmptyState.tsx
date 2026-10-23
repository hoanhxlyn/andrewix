import type { ReactNode } from "react";
import * as s from "./EmptyState.css";

interface EmptyStateProps {
  /** Message saying why there is nothing to show, or what to do next. */
  children: ReactNode;
  className?: string;
}

/** Stands in for content that is missing or cannot be shown. */
export function EmptyState({ children, className }: EmptyStateProps) {
  return (
    <p className={[s.empty, className].filter(Boolean).join(" ")}>{children}</p>
  );
}
