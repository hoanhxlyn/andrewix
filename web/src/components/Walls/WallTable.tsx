import { useAtom } from "jotai";
import { useState } from "react";
import { Collection } from "react-aria-components/Collection";
import type { SortDescriptor } from "react-aria-components/Table";
import { TableLayout, Virtualizer } from "react-aria-components/Virtualizer";
import { favoritesAtom } from "@/atoms/favorites";
import { SORT_COLUMNS, type Sort } from "@/constants";
import { nameOf, type Wall, wallId } from "@/helper/wallpapers";
import { gallery } from "@/styles/tokens.css";
import {
  Cell,
  Column,
  Pill,
  ProgressCircle,
  Row,
  Skeleton,
  Star,
  Table,
  TableBody,
  TableHeader,
  TableLoadMoreItem,
} from "@/ui";
import type { WallViewProps } from "./WallGrid";
import * as s from "./WallTable.css";

/** The column order as React Aria's descriptor, or none while the list keeps its source order. */
function descriptorOf(sort: Sort | null): SortDescriptor | undefined {
  if (sort === null) return undefined;
  return {
    column: sort.column,
    direction: sort.order === "asc" ? "ascending" : "descending",
  };
}

/** The order a pressed column heading asks for; its id is the column it heads. */
const sortOf = ({ column, direction }: SortDescriptor): Sort => ({
  column: SORT_COLUMNS.find((name) => name === column) ?? "name",
  order: direction === "ascending" ? "asc" : "desc",
});

/** A row's thumbnail, with a skeleton until the picture is there. */
function Thumbnail({ wall }: { wall: Wall }) {
  const [loaded, setLoaded] = useState(false);

  return (
    <span className={s.thumb}>
      {!loaded && <Skeleton variant="image" className={s.placeholder} />}
      <img
        className={s.image}
        src={wall.url}
        // The name is in the next cell, so the thumbnail is not read out twice.
        alt=""
        loading="lazy"
        decoding="async"
        data-loaded={loaded || undefined}
        onLoad={() => setLoaded(true)}
        onError={() => setLoaded(true)}
      />
    </span>
  );
}

/** One wallpaper of the table: thumbnail, name, source and its star. */
function WallRow({ id, wall }: { id: string; wall: Wall }) {
  const [favorites, toggleFavorite] = useAtom(favoritesAtom);
  const name = nameOf(wall.path);

  return (
    <Row id={id} textValue={name}>
      <Cell>
        {/* The virtualizer reuses a scrolled-out row for the next wallpaper. The key gives the new
            one a fresh thumbnail and skeleton instead of the old picture until the new one loads. */}
        <Thumbnail key={wall.url} wall={wall} />
      </Cell>
      <Cell>
        <span className={s.name} title={wall.path}>
          {name}
        </span>
      </Cell>
      <Cell>
        <Pill>{wall.source}</Pill>
      </Cell>
      <Cell className={s.center}>
        <Star
          aria-label="Favorite"
          isSelected={favorites.has(id)}
          onChange={() => toggleFavorite(id)}
        />
      </Cell>
    </Row>
  );
}

/**
 * The wallpapers as rows, sorted by pressing a column heading. Only the rows in view are rendered,
 * their thumbnails load lazily, and a progress circle ends the table while more remain.
 */
export function WallTable({
  walls,
  hasMore,
  onLoadMore,
  onOpen,
  sort,
  onSort,
}: WallViewProps) {
  return (
    <Virtualizer
      layout={TableLayout}
      layoutOptions={{
        rowHeight: gallery.rowHeight,
        headingHeight: gallery.headingHeight,
        loaderHeight: gallery.loaderHeight,
      }}
    >
      <Table
        aria-label="Wallpapers"
        data-testid="wall-table"
        className={s.table}
        sortDescriptor={descriptorOf(sort)}
        onSortChange={(descriptor) => onSort(sortOf(descriptor))}
        onRowAction={(key) => onOpen(String(key))}
      >
        <TableHeader>
          <Column width={gallery.pictureColumn}>Picture</Column>
          <Column id="name" isRowHeader allowsSorting>
            Name
          </Column>
          <Column id="source" width={gallery.sourceColumn} allowsSorting>
            Source
          </Column>
          <Column
            id="favorite"
            width={gallery.favoriteColumn}
            allowsSorting
            className={s.center}
          >
            Favorite
          </Column>
        </TableHeader>
        <TableBody>
          {/* `Collection` keys each element by its `id` prop; without one it keys by position, and a
              new filter would then hand an item a different id. */}
          <Collection items={walls}>
            {(wall) => <WallRow id={wallId(wall)} wall={wall} />}
          </Collection>
          {/* Loads once in view, not a viewport ahead, so the circle shows at the end of a batch. */}
          <TableLoadMoreItem
            isLoading={hasMore}
            onLoadMore={hasMore ? onLoadMore : undefined}
            scrollOffset={0}
          >
            <ProgressCircle aria-label="Loading more wallpapers" />
          </TableLoadMoreItem>
        </TableBody>
      </Table>
    </Virtualizer>
  );
}
