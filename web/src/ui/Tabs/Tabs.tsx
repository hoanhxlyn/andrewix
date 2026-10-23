import {
  type ReactElement,
  useCallback,
  useContext,
  useEffect,
  useRef,
} from "react";
import { Button } from "react-aria-components/Button";
import {
  Tab as AriaTab,
  TabList as AriaTabList,
  type TabListProps as AriaTabListProps,
  TabPanel as AriaTabPanel,
  type TabPanelProps as AriaTabPanelProps,
  type TabProps as AriaTabProps,
  Tabs as AriaTabs,
  type TabsProps as AriaTabsProps,
  TabListStateContext,
} from "react-aria-components/Tabs";
import Icons from "@/ui/Icon";
import { Tooltip } from "@/ui/Tooltip";
import * as s from "./Tabs.css";

interface TabsProps extends Omit<AriaTabsProps, "className"> {
  className?: string;
}

/**
 * Root of a tab set: holds the selection shared by its `TabList` and `TabPanel`. React Aria renders
 * a hidden copy of everything inside it to collect the tabs, except what is inside a `TabPanel`,
 * so heavy content belongs in the panel.
 */
export function Tabs({ className, ...rest }: TabsProps) {
  return (
    <AriaTabs
      className={[s.tabs, className].filter(Boolean).join(" ")}
      {...rest}
    />
  );
}

interface TabListProps<T extends object>
  extends Omit<AriaTabListProps<T>, "className" | "children"> {
  items: Iterable<T>;
  /** Renders one item as a `Tab`. */
  children: (item: T) => ReactElement;
  className?: string;
}

/** A row of tabs that scrolls sideways, keeping the selected one in view. */
export function TabList<T extends object>({
  className,
  ...rest
}: TabListProps<T>) {
  const ref = useRef<HTMLDivElement>(null);
  const selected = useContext(TabListStateContext)?.selectedKey;
  useEffect(() => {
    if (selected == null) return;
    ref.current
      ?.querySelector("[data-selected]")
      ?.scrollIntoView({ block: "nearest", inline: "nearest" });
  }, [selected]);

  return (
    <AriaTabList
      ref={ref}
      className={[s.list, className].filter(Boolean).join(" ")}
      {...rest}
    />
  );
}

interface TabProps extends Omit<AriaTabProps, "className" | "children"> {
  children: string;
  /** Text shown in a tooltip while the tab is hovered or keyboard-focused. */
  tooltip?: string;
  /** Called by the close button, or by Delete or Backspace on the focused tab. */
  onClose?: () => void;
}

/** One tab of a `TabList`, with a close button when it handles `onClose`. */
export function Tab({ children, tooltip, onClose, ...rest }: TabProps) {
  const ref = useRef<HTMLDivElement>(null);
  // React Aria's tab takes no key handler; a native listener reads the latest callback.
  const latestClose = useRef(onClose);
  latestClose.current = onClose;
  // A callback ref, not an effect: this component runs in the hidden copy, and the tab element
  // only appears later, when the list renders it.
  const attach = useCallback((tab: HTMLDivElement | null) => {
    ref.current = tab;
    if (!tab) return;
    const listeners = new AbortController();
    tab.addEventListener(
      "keydown",
      (event) => {
        if (event.target !== tab || !latestClose.current) return;
        if (event.key !== "Delete" && event.key !== "Backspace") return;
        event.preventDefault();
        latestClose.current();
      },
      { signal: listeners.signal },
    );
    return () => {
      listeners.abort();
      ref.current = null;
    };
  }, []);

  return (
    <AriaTab ref={attach} className={s.tab} {...rest}>
      {({ isHovered, isFocusVisible }) => (
        <>
          {children}
          {onClose && (
            // Out of the tab order: arrow keys move between tabs, and Delete closes the focused one.
            <Button
              className={s.close}
              aria-label={`Close ${children}`}
              excludeFromTabOrder
              onPress={onClose}
            >
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
    </AriaTab>
  );
}

interface TabPanelProps extends Omit<AriaTabPanelProps, "className"> {
  className?: string;
}

/** Content of the selected tab, filling the space under the tabs. */
export function TabPanel({ className, ...rest }: TabPanelProps) {
  return (
    <AriaTabPanel
      className={[s.panel, className].filter(Boolean).join(" ")}
      {...rest}
    />
  );
}
