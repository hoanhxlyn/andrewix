import type { ReactNode } from "react";
import * as s from "../variants/iconButton.css";

interface IconButtonProps {
  /** Accessible name; also shown as the tooltip unless `title` is set. */
  label: string;
  title?: string;
  onClick: () => void;
  /** The icon, an inline SVG that inherits the button's color. */
  children: ReactNode;
}

export function IconButton({
  label,
  title = label,
  onClick,
  children,
}: IconButtonProps) {
  return (
    <button
      type="button"
      className={s.button}
      aria-label={label}
      title={title}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
