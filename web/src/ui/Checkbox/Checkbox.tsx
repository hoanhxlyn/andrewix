import type { ReactNode } from "react";
import {
  CheckboxButton,
  CheckboxField,
  type CheckboxFieldProps,
} from "react-aria-components/Checkbox";
import Icons from "@/ui/Icon";
import * as s from "./Checkbox.css";

interface CheckboxProps
  extends Omit<CheckboxFieldProps, "className" | "children"> {
  /** Label beside the box. */
  children?: ReactNode;
  className?: string;
}

/** Checkbox with its label, for a single on/off choice. */
export function Checkbox({ children, className, ...rest }: CheckboxProps) {
  return (
    <CheckboxField className={className} {...rest}>
      <CheckboxButton className={s.checkbox}>
        {({ isSelected }) => (
          <>
            <span className={s.box}>
              {isSelected && <Icons.Check aria-hidden />}
            </span>
            {children}
          </>
        )}
      </CheckboxButton>
    </CheckboxField>
  );
}
