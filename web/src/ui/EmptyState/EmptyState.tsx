import { cloneElement, type ReactElement, type ReactNode } from "react";
import * as s from "./EmptyState.css";

interface EmptyStateProps {
  /** Decorative inline SVG shown above the message. Hidden from assistive tech. */
  icon: ReactElement<{ "aria-hidden"?: boolean }>;
  /** Message saying why there is nothing to show, or what to do next. */
  children: ReactNode;
  className?: string;
}

/** Stands in for content that is missing or cannot be shown. */
export function EmptyState({ icon, children, className }: EmptyStateProps) {
  return (
    <div className={[s.empty, className].filter(Boolean).join(" ")}>
      {cloneElement(icon, { "aria-hidden": true })}
      <p className={s.message}>{children}</p>
    </div>
  );
}
