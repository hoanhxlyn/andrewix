import { clsx } from "clsx";
import { useEffect, useRef, useState } from "react";
import { Input } from "react-aria-components/Input";
import {
  SearchField as AriaSearchField,
  type SearchFieldProps as AriaSearchFieldProps,
} from "react-aria-components/SearchField";
import { COMMIT_DELAY_MS } from "@/constants";
import { Button } from "@/ui/Button";
import Icons from "@/ui/Icon";
import * as s from "./SearchField.css";

interface SearchFieldProps
  extends Omit<
    AriaSearchFieldProps,
    "className" | "value" | "onChange" | "children"
  > {
  /** Current query text. */
  value: string;
  /** Called with the new query text once typing pauses, and at once when it is cleared. */
  onChange: (value: string) => void;
  /** Short hint shown while the field is empty. */
  placeholder?: string;
  className?: string;
}

/**
 * Search input with a leading icon and, while it holds text, a clear button. The text being
 * typed lives here, so a keystroke only re-renders the field; the page hears about it when typing
 * pauses.
 */
export function SearchField({
  value,
  onChange,
  placeholder,
  className,
  ...rest
}: SearchFieldProps) {
  const [draft, setDraft] = useState(value);
  // The last text reported to the page, to tell its echo from a change made elsewhere.
  const committed = useRef(value);
  const input = useRef<HTMLInputElement>(null);
  const report = useRef(onChange);
  report.current = onChange;

  useEffect(() => {
    if (value === committed.current) return;
    committed.current = value;
    setDraft(value);
  }, [value]);

  useEffect(() => {
    if (draft === committed.current) return;
    const timer = setTimeout(() => {
      committed.current = draft;
      report.current(draft);
    }, COMMIT_DELAY_MS);
    return () => clearTimeout(timer);
  }, [draft]);

  return (
    <AriaSearchField
      value={draft}
      onChange={setDraft}
      aria-label="Search files"
      className={clsx(s.field, className)}
      {...rest}
    >
      <Icons.Search aria-hidden />
      <Input ref={input} className={s.input} placeholder={placeholder} />
      {/* Shown only while there is text to clear, as Material's search view does. It stays
          mounted so it can fade out; the styles hide it from the tab order once it has. */}
      <Button
        variant="icon"
        icon={<Icons.Close />}
        aria-label="Clear search"
        onPress={() => {
          committed.current = "";
          setDraft("");
          onChange("");
          // The button leaves with the text; focus goes back to the input instead of the page.
          input.current?.focus();
        }}
      />
    </AriaSearchField>
  );
}
