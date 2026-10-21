import type { ReactNode } from "react";
import { type CardVariants, card } from "../variants/card.css";

interface CardProps extends CardVariants {
  children: ReactNode;
}

export function Card({ variant, children }: CardProps) {
  return <div className={card({ variant })}>{children}</div>;
}
