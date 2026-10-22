import type { ComponentPropsWithoutRef } from "react";
import { type CardVariants, card } from "./Card.css";

interface CardProps
  extends CardVariants,
    Omit<ComponentPropsWithoutRef<"div">, "className"> {
  /** Extra classes to compose with the card recipe. */
  className?: string;
}

export function Card({ variant, className, ...rest }: CardProps) {
  return (
    <div
      className={[card({ variant }), className].filter(Boolean).join(" ")}
      {...rest}
    />
  );
}
