import { Children, type ReactElement, type ReactNode } from "react";
import {
  Menu as AriaMenu,
  MenuItem as AriaMenuItem,
  type MenuItemProps as AriaMenuItemProps,
  type MenuProps as AriaMenuProps,
  MenuTrigger as AriaMenuTrigger,
  type MenuTriggerProps as AriaMenuTriggerProps,
  Popover,
} from "react-aria-components/Menu";
import Icons from "@/ui/Icon";
import * as s from "./Menu.css";

interface MenuTriggerProps extends Omit<AriaMenuTriggerProps, "children"> {
  /** The button that opens the menu, then the `Menu` itself. */
  children: [ReactElement, ReactElement];
}

/** Opens its `Menu` in a popover under the button given as the first child. */
export function MenuTrigger({ children, ...rest }: MenuTriggerProps) {
  const [trigger, menu] = Children.toArray(children);
  return (
    <AriaMenuTrigger {...rest}>
      {trigger}
      <Popover className={s.popover}>{menu}</Popover>
    </AriaMenuTrigger>
  );
}

type MenuProps<T> = Omit<AriaMenuProps<T>, "className">;

/** List of actions or choices, for use inside a `MenuTrigger`. */
export function Menu<T extends object>(props: MenuProps<T>) {
  return <AriaMenu className={s.menu} {...props} />;
}

interface MenuItemProps
  extends Omit<AriaMenuItemProps, "className" | "children"> {
  children: ReactNode;
}

/** One item of a `Menu`; in a menu that selects, the picked item carries a check mark. */
export function MenuItem({ children, textValue, ...rest }: MenuItemProps) {
  return (
    <AriaMenuItem
      className={s.item}
      textValue={
        textValue ?? (typeof children === "string" ? children : undefined)
      }
      {...rest}
    >
      {({ isSelected, selectionMode }) => (
        <>
          {selectionMode !== "none" && (
            <span className={s.check}>
              {isSelected && <Icons.Check aria-hidden />}
            </span>
          )}
          {children}
        </>
      )}
    </AriaMenuItem>
  );
}
