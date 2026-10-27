import { clsx } from "clsx";
import type { ReactNode } from "react";
import {
  Cell as AriaCell,
  type CellProps as AriaCellProps,
  Column as AriaColumn,
  type ColumnProps as AriaColumnProps,
  Row as AriaRow,
  type RowProps as AriaRowProps,
  Table as AriaTable,
  TableBody as AriaTableBody,
  type TableBodyProps as AriaTableBodyProps,
  TableHeader as AriaTableHeader,
  type TableHeaderProps as AriaTableHeaderProps,
  TableLoadMoreItem as AriaTableLoadMoreItem,
  type TableLoadMoreItemProps as AriaTableLoadMoreItemProps,
  type TableProps as AriaTableProps,
} from "react-aria-components/Table";
import Icons from "@/ui/Icon";
import * as s from "./Table.css";

interface TableProps extends Omit<AriaTableProps, "className"> {
  className?: string;
}

/**
 * Table of rows a user can move through with the arrow keys. Wrap it in a `Virtualizer` with
 * `TableLayout` to render only the rows in view.
 */
export function Table({ className, ...rest }: TableProps) {
  return <AriaTable className={clsx(s.table, className)} {...rest} />;
}

/** Header row of a `Table`, holding its `Column`s. */
export function TableHeader<T extends object>(
  props: Omit<AriaTableHeaderProps<T>, "className">,
) {
  return <AriaTableHeader {...props} />;
}

interface ColumnProps extends Omit<AriaColumnProps, "className" | "children"> {
  className?: string;
  children?: ReactNode;
}

/**
 * One column heading of a `Table`. With `allowsSorting` it is pressable and shows the arrow of the
 * order it is sorted in, while the `Table` of it holds the `sortDescriptor`.
 */
export function Column({ className, children, ...rest }: ColumnProps) {
  return (
    <AriaColumn
      // The render-prop children hide the heading text from the collection, which builds the
      // sort announcement ("Sorted by …") from the column's `textValue`; supply it ourselves.
      textValue={
        rest.textValue ?? (typeof children === "string" ? children : undefined)
      }
      className={clsx(s.column, className)}
      {...rest}
    >
      {({ sortDirection }) => (
        <>
          <span className={s.heading}>{children}</span>
          {sortDirection !== undefined && (
            <Icons.Chevron
              aria-hidden
              className={clsx(
                s.sortIndicator,
                sortDirection === "descending" && s.sortIndicatorDescending,
              )}
            />
          )}
        </>
      )}
    </AriaColumn>
  );
}

/** Body of a `Table`, holding its `Row`s. */
export function TableBody<T extends object>(
  props: Omit<AriaTableBodyProps<T>, "className">,
) {
  return <AriaTableBody {...props} />;
}

/** One row of a `Table`. */
export function Row<T extends object>(
  props: Omit<AriaRowProps<T>, "className">,
) {
  return <AriaRow className={s.row} {...props} />;
}

interface CellProps extends Omit<AriaCellProps, "className"> {
  className?: string;
}

/** One cell of a `Row`. */
export function Cell({ className, ...rest }: CellProps) {
  return <AriaCell className={clsx(s.cell, className)} {...rest} />;
}

/**
 * Last row of a `TableBody`: asks for more rows with `onLoadMore` once it scrolls into view, and
 * shows its children, usually a `ProgressCircle`, while `isLoading`.
 */
export function TableLoadMoreItem(
  props: Omit<AriaTableLoadMoreItemProps, "className">,
) {
  return <AriaTableLoadMoreItem className={s.loader} {...props} />;
}
