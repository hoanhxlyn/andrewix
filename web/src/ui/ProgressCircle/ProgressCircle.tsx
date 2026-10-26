import { clsx } from "clsx";
import { ProgressBar } from "react-aria-components/ProgressBar";
import { progress } from "@/styles/tokens.css";
import * as s from "./ProgressCircle.css";

const CENTER = progress.size / 2;
// Inset by half the stroke, so the arc stays inside the box.
const RADIUS = (progress.size - progress.stroke) / 2;

interface ProgressCircleProps {
  /** What is in progress, since the circle shows no text. */
  "aria-label": string;
  className?: string;
}

/** Turning arc for work of unknown length, such as the next batch of a list. */
export function ProgressCircle({ className, ...rest }: ProgressCircleProps) {
  return (
    <ProgressBar isIndeterminate className={clsx(s.root, className)} {...rest}>
      <svg
        className={s.svg}
        viewBox={`0 0 ${progress.size} ${progress.size}`}
        aria-hidden
      >
        <circle
          className={s.arc}
          cx={CENTER}
          cy={CENTER}
          r={RADIUS}
          strokeWidth={progress.stroke}
          pathLength={100}
        />
      </svg>
    </ProgressBar>
  );
}
