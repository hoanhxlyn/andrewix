import type { ComponentPropsWithoutRef } from "react";
import * as s from "./Grid.css";

type GridProps = Omit<ComponentPropsWithoutRef<"div">, "className">;

/** Column grid for page content. */
export function Grid(props: GridProps) {
  return <div className={s.grid} {...props} />;
}
