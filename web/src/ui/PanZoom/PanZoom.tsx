import { assignInlineVars } from "@vanilla-extract/dynamic";
import type { ComponentPropsWithoutRef } from "react";
import * as s from "./PanZoom.css";
import { usePanZoom } from "./usePanZoom";

/**
 * Shows `children` on a surface that is dragged to pan and scrolled or pinched to zoom, like a
 * map. Dragging that starts on a button does not pan, so buttons inside stay pressable.
 */
export function PanZoom({
  children,
  className,
  ...rest
}: ComponentPropsWithoutRef<"div">) {
  const { ref, dragging, view, handlers } = usePanZoom();

  return (
    <div
      {...rest}
      {...handlers}
      ref={ref}
      className={[s.viewport, className].filter(Boolean).join(" ")}
      data-dragging={dragging || undefined}
    >
      <div
        className={s.surface}
        style={assignInlineVars({
          [s.panX]: `${view.x}px`,
          [s.panY]: `${view.y}px`,
          [s.scale]: String(view.scale),
        })}
      >
        {children}
      </div>
    </div>
  );
}
