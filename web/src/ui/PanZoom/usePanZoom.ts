import { type PointerEvent, useEffect, useRef, useState } from "react";
import { clamp } from "remeda";

const MIN_SCALE = 0.25;
const MAX_SCALE = 2;
/** Zoom change per wheel delta unit. */
const WHEEL_SENSITIVITY = 0.002;

interface View {
  x: number;
  y: number;
  scale: number;
}

const INITIAL_VIEW: View = { x: 0, y: 0, scale: 1 };

/** Scales `view` by `factor` while keeping the point (`px`, `py`) of the viewport fixed. */
function zoom(view: View, px: number, py: number, factor: number): View {
  const scale = clamp(view.scale * factor, { min: MIN_SCALE, max: MAX_SCALE });
  const ratio = scale / view.scale;
  return {
    scale,
    x: px - (px - view.x) * ratio,
    y: py - (py - view.y) * ratio,
  };
}

/**
 * State and event handlers for a viewport that is dragged to pan and scrolled or pinched to zoom.
 * Dragging that starts on a button does not pan, so buttons inside stay pressable.
 */
export function usePanZoom() {
  const ref = useRef<HTMLDivElement>(null);
  const lastPointer = useRef<{ x: number; y: number } | null>(null);
  const [view, setView] = useState(INITIAL_VIEW);
  const [dragging, setDragging] = useState(false);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;
    // React registers wheel listeners as passive, so this one is added by hand to stop the page scrolling.
    const onWheel = (event: WheelEvent) => {
      event.preventDefault();
      const box = element.getBoundingClientRect();
      const factor = Math.exp(-event.deltaY * WHEEL_SENSITIVITY);
      setView((current) =>
        zoom(
          current,
          event.clientX - box.left,
          event.clientY - box.top,
          factor,
        ),
      );
    };
    const controller = new AbortController();
    element.addEventListener("wheel", onWheel, {
      passive: false,
      signal: controller.signal,
    });
    return () => controller.abort();
  }, []);

  const endDrag = () => {
    lastPointer.current = null;
    setDragging(false);
  };

  const onPointerDown = (event: PointerEvent<HTMLDivElement>) => {
    if (event.button !== 0) return;
    if ((event.target as Element).closest("button")) return;
    event.currentTarget.setPointerCapture(event.pointerId);
    lastPointer.current = { x: event.clientX, y: event.clientY };
    setDragging(true);
  };

  const onPointerMove = (event: PointerEvent<HTMLDivElement>) => {
    const last = lastPointer.current;
    if (!last) return;
    const dx = event.clientX - last.x;
    const dy = event.clientY - last.y;
    lastPointer.current = { x: event.clientX, y: event.clientY };
    setView((current) => ({
      ...current,
      x: current.x + dx,
      y: current.y + dy,
    }));
  };

  return {
    /** Ref for the viewport element. */
    ref,
    /** Whether a drag is in progress. */
    dragging,
    /** Offset and scale of the surface that moves inside the viewport. */
    view,
    /** Pointer handlers for the viewport element. */
    handlers: {
      onPointerDown,
      onPointerMove,
      onPointerUp: endDrag,
      onPointerCancel: endDrag,
    },
  };
}
