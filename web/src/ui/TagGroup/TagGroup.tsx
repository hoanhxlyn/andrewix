import { type ReactElement, useEffect, useRef } from "react";
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
    <AriaTagGroup
      className={[s.group, className].filter(Boolean).join(" ")}
      {...rest}
    >
      <TagList ref={listRef} items={items} className={s.list}>
        {children}
      </TagList>
    </AriaTagGroup>
  );
}

interface TagProps extends Omit<AriaTagProps, "className" | "children"> {
  children: string;
  /** Text shown in a tooltip while the tag is hovered or keyboard-focused. */
  tooltip?: string;
}

/** One tag of a `TagGroup`, with a remove button when the group handles `onRemove`. */
export function Tag({ children, tooltip, ...rest }: TagProps) {
  const ref = useRef<HTMLDivElement>(null);

  return (
    <AriaTag ref={ref} textValue={children} className={s.tag} {...rest}>
      {({ allowsRemoving, isHovered, isFocusVisible }) => (
        <>
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
