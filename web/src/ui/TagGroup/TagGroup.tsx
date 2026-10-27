import { clsx } from "clsx";
import { cloneElement, type ReactElement, useEffect, useRef } from "react";
import {
  Tag as AriaTag,
  TagGroup as AriaTagGroup,
  type TagGroupProps as AriaTagGroupProps,
  type TagProps as AriaTagProps,
  Button,
  TagList,
} from "react-aria-components/TagGroup";
import Icons from "@/ui/Icon";
import { Tooltip } from "@/ui/Tooltip";
import * as s from "./TagGroup.css";

interface TagGroupProps<T extends object>
  extends Omit<AriaTagGroupProps, "className" | "children"> {
  items: Iterable<T>;
  /** Renders one item as a `Tag`. */
  children: (item: T) => ReactElement;
  className?: string;
}

/** A row of tags that scrolls sideways, keeping the selected one in view. */
export function TagGroup<T extends object>({
  items,
  children,
  className,
  ...rest
}: TagGroupProps<T>) {
  const listRef = useRef<HTMLDivElement>(null);
  const selected =
    rest.selectedKeys === "all" ? "" : [...(rest.selectedKeys ?? [])].join();
  useEffect(() => {
    if (selected === "") return;
    listRef.current
      ?.querySelector("[data-selected]")
      ?.scrollIntoView({ block: "nearest", inline: "nearest" });
  }, [selected]);

  return (
    <AriaTagGroup className={clsx(s.group, className)} {...rest}>
      <TagList ref={listRef} items={items} className={s.list}>
        {children}
      </TagList>
    </AriaTagGroup>
  );
}

interface TagProps extends Omit<AriaTagProps, "className" | "children"> {
  children: string;
  /**
   * Decorative icon before the label. A selected tag shows a check mark there instead, with or
   * without an icon of its own, as on a Material filter chip.
   */
  icon?: ReactElement<{ "aria-hidden"?: boolean }>;
  /** Text shown in a tooltip while the tag is hovered or keyboard-focused. */
  tooltip?: string;
}

/** One tag of a `TagGroup`, with a remove button when the group handles `onRemove`. */
export function Tag({ children, icon, tooltip, ...rest }: TagProps) {
  const ref = useRef<HTMLDivElement>(null);

  return (
    <AriaTag ref={ref} textValue={children} className={s.tag} {...rest}>
      {({ allowsRemoving, isHovered, isFocusVisible, isSelected }) => (
        <>
          {isSelected ? (
            <Icons.Check aria-hidden />
          ) : (
            icon && cloneElement(icon, { "aria-hidden": true })
          )}
          {children}
          {allowsRemoving && (
            <Button slot="remove" className={s.remove}>
              <Icons.Close aria-hidden />
            </Button>
          )}
          {/* Mounted only while open, like the tree's name tooltips. */}
          {tooltip && (isHovered || isFocusVisible) && (
            <Tooltip triggerRef={ref} isOpen>
              {tooltip}
            </Tooltip>
          )}
        </>
      )}
    </AriaTag>
  );
}
