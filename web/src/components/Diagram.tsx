import { mount } from "ondine";
import { useEffect, useRef } from "react";

interface DiagramProps {
  /** A compiled diagram, the default export of a `.mmd` import. */
  diagram: { readonly svg: string };
}

/** Renders a diagram compiled at build time by Ondine. */
export function Diagram({ diagram }: DiagramProps) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;
    const handle = mount(element, diagram);
    return () => handle.unmount();
  }, [diagram]);

  return <div ref={ref} />;
}
