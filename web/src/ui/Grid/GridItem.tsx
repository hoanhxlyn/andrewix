import type { ComponentPropsWithoutRef } from "react";
import { columns } from "@/styles/tokens.css";
import * as s from "./GridItem.css";

type WindowClass = keyof typeof columns;

// 1 to N, so a span can never exceed the column count and create implicit columns.
type UpTo<N extends number, Acc extends number[] = []> = Acc["length"] extends N
  ? Exclude<Acc[number] | N, 0>
  : UpTo<N, [...Acc, Acc["length"]]>;

type Span = { [K in WindowClass]?: UpTo<(typeof columns)[K]> };

interface GridItemProps
  extends Omit<ComponentPropsWithoutRef<"div">, "className"> {
  /** Columns to span per window class. A class left out keeps the span of the smaller one. */
  span?: Span;
}

const windowClasses = Object.keys(columns) as WindowClass[];

/** Child of `Grid` that spans several columns. Without `span` it takes one column. */
export function GridItem({ span = {}, ...rest }: GridItemProps) {
  const className = windowClasses
    .map((windowClass) => {
      const count = span[windowClass];
      return count && s.span[windowClass][count];
    })
    .filter(Boolean)
    .join(" ");
  return <div className={className || undefined} {...rest} />;
}
