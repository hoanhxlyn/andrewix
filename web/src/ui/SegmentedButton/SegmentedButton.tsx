import { clsx } from "clsx";
import { cloneElement, type ReactElement } from "react";
import {
  ToggleButton,
  ToggleButtonGroup,
  type ToggleButtonGroupProps,
  type ToggleButtonProps,
} from "react-aria-components/ToggleButtonGroup";
import Icons from "@/ui/Icon";
import * as s from "./SegmentedButton.css";

interface SegmentedButtonProps
  extends Omit<ToggleButtonGroupProps, "className"> {
  className?: string;
}

/** A row of segments to pick one option from, or several with `selectionMode="multiple"`. */
export function SegmentedButton({ className, ...rest }: SegmentedButtonProps) {
  return <ToggleButtonGroup className={clsx(s.group, className)} {...rest} />;
}

interface SegmentProps
  extends Omit<ToggleButtonProps, "className" | "children"> {
  /** Icon of the segment. Without a label, the segment needs an `aria-label`. */
  icon?: ReactElement<{ "aria-hidden"?: boolean }>;
  children?: string;
}

/**
 * One segment of a `SegmentedButton`. A selected segment with a label shows a check mark in place
 * of its icon, as in Material; an icon-only one keeps its icon, which is all it has to show.
 */
export function Segment({ icon, children, ...rest }: SegmentProps) {
  return (
    <ToggleButton className={s.segment} {...rest}>
      {({ isSelected }) => (
        <>
          {isSelected && children ? (
            <Icons.Check aria-hidden />
          ) : (
            icon && cloneElement(icon, { "aria-hidden": true })
          )}
          {children}
        </>
      )}
    </ToggleButton>
  );
}
