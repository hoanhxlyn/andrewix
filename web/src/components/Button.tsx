import type { ReactNode } from "react";
import { type ButtonVariants, button } from "../variants/button.css";

interface ButtonProps extends ButtonVariants {
  /** Optional leading icon, an inline SVG that inherits the button's color. */
  icon?: ReactNode;
  disabled?: boolean;
  type?: "button" | "submit";
  onClick?: () => void;
  children: ReactNode;
}

export function Button({
  variant,
  icon,
  disabled,
  type = "button",
  onClick,
  children,
}: ButtonProps) {
  return (
    <button
      type={type}
      className={button({ variant })}
      disabled={disabled}
      onClick={onClick}
    >
      {icon}
      {children}
    </button>
  );
}
