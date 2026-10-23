import { style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { breakpoints, columns } from "@/styles/tokens.css";

type Media = keyof typeof breakpoints;

// One class per span, from 1 up to the column count of the window class.
function spans(count: number, media?: Media) {
  return Object.fromEntries(
    Array.from({ length: count }, (_, i) => {
      const rule = { gridColumn: `span ${i + 1}` };
      return [
        i + 1,
        style(
          inComponents(
            media ? { "@media": { [breakpoints[media]]: rule } } : rule,
          ),
        ),
      ];
    }),
  ) as Record<number, string>;
}

/**
 * Column span classes per window class, keyed by span. A larger window class is declared after
 * a smaller one, so it wins when both apply.
 */
export const span = {
  compact: spans(columns.compact),
  medium: spans(columns.medium, "medium"),
  expanded: spans(columns.expanded, "expanded"),
};
