import type { ComponentPropsWithoutRef, ReactNode } from "react";
import { type ButtonVariants, button } from "./Button.css";

interface ButtonProps
  extends ButtonVariants,
    Omit<ComponentPropsWithoutRef<"button">, "className"> {
  /** Optional leading icon, an inline SVG that inherits the button's color. */
  icon?: ReactNode;
}

export function Button({
  variant,
  icon,
  type = "button",
  children,
  ...rest
}: ButtonProps) {
  return (
    <button type={type} className={button({ variant })} {...rest}>
      {icon}
      {children}
    </button>
  );
}
