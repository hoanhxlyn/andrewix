import { useLayoutEffect, useRef, useState } from "react";
import { Tooltip } from "@/ui/Tooltip";

interface NameProps {
  text: string;
  /** Whether the row is hovered or keyboard-focused, the moments a hidden name shows in full. */
  isActive: boolean;
}

/** Whether part of the element lies outside the nearest ancestor that clips it horizontally. */
function isClipped(el: HTMLElement): boolean {
  let clip = el.parentElement;
  while (clip && getComputedStyle(clip).overflowX === "visible") {
    clip = clip.parentElement;
  }
  if (!clip) return false;
  const box = el.getBoundingClientRect();
  // The visible area excludes the clipping element's border and scrollbar.
  const left = clip.getBoundingClientRect().left + clip.clientLeft;
  return box.left < left || box.right > left + clip.clientWidth;
}

/** Name of a row, with a tooltip of the full name while the row is active and the name is hidden. */
export function Name({ text, isActive }: NameProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const [isHidden, setIsHidden] = useState(false);
  // Measured only when the row becomes active, so idle rows do no layout reads.
  useLayoutEffect(() => {
    if (!isActive) return;
    setIsHidden(ref.current !== null && isClipped(ref.current));
  }, [isActive]);

  return (
    <>
      <span ref={ref}>{text}</span>
      {/* Mounted only while open: hundreds of rows would otherwise each carry overlay state. */}
      {isActive && isHidden && (
        <Tooltip triggerRef={ref} isOpen>
          {text}
        </Tooltip>
      )}
    </>
  );
}
