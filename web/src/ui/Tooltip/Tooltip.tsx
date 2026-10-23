import {
  Tooltip as AriaTooltip,
  type TooltipProps as AriaTooltipProps,
  TooltipTrigger,
} from "react-aria-components/Tooltip";
import * as s from "./Tooltip.css";

interface TooltipProps extends Omit<AriaTooltipProps, "className"> {
  className?: string;
}

/**
 * Tooltip styled for the app. Use it inside a `TooltipTrigger`, or standalone with `triggerRef`
 * and `isOpen` when the trigger is not focusable on its own.
 */
export function Tooltip({ className, isOpen, ...rest }: TooltipProps) {
  const classes = [s.tooltip, className].filter(Boolean).join(" ");
  if (!rest.triggerRef) return <AriaTooltip className={classes} {...rest} />;
  // React Aria 1.22.1 positions a tooltip from the trigger's state context even when it is used
  // standalone, and crashes without one; a controlled trigger supplies it.
  return (
    <TooltipTrigger isOpen={isOpen}>
      <AriaTooltip className={classes} {...rest} />
    </TooltipTrigger>
  );
}
