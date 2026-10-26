import { clsx } from "clsx";
import type { ComponentPropsWithoutRef } from "react";
import { type PillVariants, pill } from "./Pill.css";

interface PillProps
  extends PillVariants,
    Omit<ComponentPropsWithoutRef<"span">, "className"> {
  /** Extra classes to compose with the pill recipe. */
  className?: string;
}

export function Pill({ variant, className, ...rest }: PillProps) {
  return <span className={clsx(pill({ variant }), className)} {...rest} />;
}
