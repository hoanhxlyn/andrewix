import type { ComponentPropsWithoutRef } from "react";
import { type CardVariants, card } from "./Card.css";

interface CardProps
  extends CardVariants,
    Omit<ComponentPropsWithoutRef<"div">, "className"> {}

export function Card({ variant, ...rest }: CardProps) {
  return <div className={card({ variant })} {...rest} />;
}
