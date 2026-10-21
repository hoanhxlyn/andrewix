import type { ReactNode } from "react";
import * as s from "./Grid.css";

interface GridProps {
  children: ReactNode;
}

/** Column grid for page content. */
export function Grid({ children }: GridProps) {
  return <div className={s.grid}>{children}</div>;
}
