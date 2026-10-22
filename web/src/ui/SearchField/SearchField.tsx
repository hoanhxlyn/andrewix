import { Input } from "react-aria-components/Input";
import {
  SearchField as AriaSearchField,
  type SearchFieldProps as AriaSearchFieldProps,
} from "react-aria-components/SearchField";
import { Button } from "@/ui/Button";
import CloseIcon from "~icons/mdi/close";
import SearchIcon from "~icons/mdi/magnify";
import * as s from "./SearchField.css";

interface SearchFieldProps
  extends Omit<
    AriaSearchFieldProps,
    "className" | "value" | "onChange" | "children"
  > {
  /** Current query text. */
  value: string;
  /** Called with the new query text as it changes. */
  onChange: (value: string) => void;
  /** Short hint shown while the field is empty. */
  placeholder?: string;
  className?: string;
}

/** Search input with a leading icon and a clear button. */
export function SearchField({
  value,
  onChange,
  placeholder,
  className,
  ...rest
}: SearchFieldProps) {
  return (
    <AriaSearchField
      value={value}
      onChange={onChange}
      aria-label="Search files"
      className={[s.field, className].filter(Boolean).join(" ")}
      {...rest}
    >
      <SearchIcon aria-hidden />
      <Input className={s.input} placeholder={placeholder} />
      <Button
        variant="icon"
        icon={<CloseIcon />}
        aria-label="Clear search"
        isDisabled={value === ""}
        onPress={() => onChange("")}
      />
    </AriaSearchField>
  );
}
