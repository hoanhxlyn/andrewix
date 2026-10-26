import { clsx } from "clsx";
import type { ComponentPropsWithoutRef } from "react";
import { type BadgeVariants, badge } from "./Badge.css";

interface BadgeProps
  extends BadgeVariants,
    Omit<ComponentPropsWithoutRef<"span">, "className"> {
  /** Extra classes to compose with the badge recipe. */
  className?: string;
}

export function Badge({ variant, className, ...rest }: BadgeProps) {
  return <span className={clsx(badge({ variant }), className)} {...rest} />;
}
