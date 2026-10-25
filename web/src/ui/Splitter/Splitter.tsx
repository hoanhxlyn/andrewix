import { type KeyboardEvent, useRef, useState } from "react";
import { mergeProps } from "react-aria/mergeProps";
import { useFocusRing } from "react-aria/useFocusRing";
import { useHover } from "react-aria/useHover";
import { useMove } from "react-aria/useMove";
import { clamp } from "remeda";
import * as s from "./Splitter.css";

interface SplitterProps {
  /** Width of the pane before the splitter, in pixels. */
  value: number;
  min: number;
  max: number;
  /** Pixels one arrow key press moves the splitter. */
  step: number;
  /** Width a double click puts the pane back to. */
  resetValue: number;
  /** Called with the new width, already kept between `min` and `max`. */
  onChange: (value: number) => void;
  "aria-label": string;
  /** Id of the pane the splitter resizes. */
  "aria-controls"?: string;
  className?: string;
}

/**
 * Vertical divider that resizes the pane before it: dragged with a pointer, or moved with the arrow
 * keys and sent to either limit with Home and End once focused. A double click resets the width.
 */
export function Splitter({
  value,
  min,
  max,
  step,
  resetValue,
  onChange,
  className,
  ...rest
}: SplitterProps) {
  // Where the drag would put the edge without the limits, so after dragging past one the pane
  // only moves again once the pointer is back inside the range.
  const dragged = useRef(value);
  const [isDragging, setDragging] = useState(false);
  const { moveProps } = useMove({
    onMoveStart: () => {
      dragged.current = value;
      setDragging(true);
    },
    onMove: ({ pointerType, deltaX }) => {
      dragged.current += pointerType === "keyboard" ? deltaX * step : deltaX;
      onChange(clamp(dragged.current, { min, max }));
    },
    onMoveEnd: () => setDragging(false),
  });
  const { hoverProps, isHovered } = useHover({});
  const { focusProps, isFocusVisible } = useFocusRing();
  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key !== "Home" && event.key !== "End") return;
    event.preventDefault();
    onChange(event.key === "Home" ? min : max);
  };

  return (
    // A focusable separator is the window-splitter pattern: <hr> already carries the role, and it
    // takes the ARIA values and the drag handlers like any other element.
    <hr
      aria-orientation="vertical"
      aria-valuenow={value}
      aria-valuemin={min}
      aria-valuemax={max}
      tabIndex={0}
      className={[s.splitter, className].filter(Boolean).join(" ")}
      data-hovered={isHovered || undefined}
      data-dragging={isDragging || undefined}
      data-focus-visible={isFocusVisible || undefined}
      {...mergeProps(
        moveProps,
        hoverProps,
        focusProps,
        { onKeyDown, onDoubleClick: () => onChange(resetValue) },
        rest,
      )}
    />
  );
}
