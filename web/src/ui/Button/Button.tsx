import { cloneElement, type ReactElement, type ReactNode } from "react";
import {
  Button as AriaButton,
  type ButtonProps as AriaButtonProps,
} from "react-aria-components/Button";
import { type ButtonVariants, button } from "./Button.css";

type Variant = NonNullable<ButtonVariants["variant"]>;
type Icon = ReactElement<{ "aria-hidden"?: boolean }>;

interface BaseProps extends Omit<AriaButtonProps, "className" | "children"> {
  /** Decorative inline SVG that inherits the button's color. Hidden from assistive tech. */
  icon?: Icon;
}

interface LabelledProps extends BaseProps {
  variant?: Exclude<Variant, "icon">;
  children: ReactNode;
}

/** An icon-only button has no text, so it must carry an accessible name. */
interface IconOnlyProps extends BaseProps {
  variant: "icon";
  icon: Icon;
  "aria-label": string;
  children?: never;
}

type ButtonProps = LabelledProps | IconOnlyProps;

export function Button({
  variant,
  icon,
  type = "button",
  children,
  ...rest
}: ButtonProps) {
  return (
    <AriaButton type={type} className={button({ variant })} {...rest}>
      {icon && cloneElement(icon, { "aria-hidden": true })}
      {children}
    </AriaButton>
  );
}
