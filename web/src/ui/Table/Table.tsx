import { clsx } from "clsx";
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

/** One column heading of a `Table`. */
export function Column(props: Omit<AriaColumnProps, "className">) {
  return <AriaColumn className={s.column} {...props} />;
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

/** One cell of a `Row`. */
export function Cell(props: Omit<AriaCellProps, "className">) {
  return <AriaCell className={s.cell} {...props} />;
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
