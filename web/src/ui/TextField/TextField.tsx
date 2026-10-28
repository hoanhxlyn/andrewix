import { clsx } from "clsx";
import { Input } from "react-aria-components/Input";
import { Label } from "react-aria-components/Label";
import {
  TextField as AriaTextField,
  type TextFieldProps as AriaTextFieldProps,
} from "react-aria-components/TextField";
import * as s from "./TextField.css";

interface TextFieldProps
  extends Omit<AriaTextFieldProps, "className" | "children"> {
  /** Label above the input, which also names it for assistive tech. */
  label: string;
  className?: string;
}

/** Single-line text input with its label, for a value the page keeps as it is typed. */
export function TextField({ label, className, ...rest }: TextFieldProps) {
  return (
    <AriaTextField className={clsx(s.field, className)} {...rest}>
      <Label className={s.label}>{label}</Label>
      <Input className={s.input} />
    </AriaTextField>
  );
}
