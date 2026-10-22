import { mount } from "ondine";
import { type ComponentPropsWithoutRef, useEffect, useRef } from "react";

interface DiagramProps
  extends Omit<
    ComponentPropsWithoutRef<"div">,
    "children" | "dangerouslySetInnerHTML"
  > {
  /** A compiled diagram, the default export of a `.mmd` import. */
  diagram: { readonly svg: string };
}

/** Renders a diagram compiled at build time by Ondine. */
export function Diagram({ diagram, ...rest }: DiagramProps) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;
    const handle = mount(element, diagram.svg);
    return () => handle.unmount();
  }, [diagram.svg]);

  return <div ref={ref} {...rest} />;
}
