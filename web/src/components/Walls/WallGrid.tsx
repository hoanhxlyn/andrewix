import { useAtom } from "jotai";
import { useState, useSyncExternalStore } from "react";
import { Collection } from "react-aria-components/Collection";
import {
  GridList,
  GridListItem,
  GridListLoadMoreItem,
} from "react-aria-components/GridList";
import {
  GridLayout,
  Size,
  Virtualizer,
} from "react-aria-components/Virtualizer";
import { favoritesAtom } from "@/atoms/favorites";
import type { Sort } from "@/constants";
import { nameOf, type Wall, wallId } from "@/helper/wallpapers";
import { breakpoints, gallery } from "@/styles/tokens.css";
import { Pill, ProgressCircle, Skeleton, Star } from "@/ui";
import * as s from "./WallGrid.css";

const expanded = () => window.matchMedia(breakpoints.expanded);
const medium = () => window.matchMedia(breakpoints.medium);

function subscribe(onChange: () => void): () => void {
  const controller = new AbortController();
  for (const query of [expanded(), medium()]) {
    query.addEventListener("change", onChange, { signal: controller.signal });
  }
  return () => controller.abort();
}

/** Cards per row in the current window class, as the layout grid of the rest of the app. */
function cardsPerRow(): number {
  if (expanded().matches) return gallery.cardsPerRow.expanded;
  if (medium().matches) return gallery.cardsPerRow.medium;
  return gallery.cardsPerRow.compact;
}

/** Narrow enough that the cap per window class, not the card width, sets the column count. */
const MIN_CARD = new Size(gallery.minCardWidth, gallery.minCardWidth);
const GAP = new Size(gallery.gap, gallery.gap);

export interface WallViewProps {
  /** The wallpapers loaded so far. */
  walls: readonly Wall[];
  /** Whether more wallpapers match than `walls` holds. */
  hasMore: boolean;
  /** Adds the next batch to `walls`; called once the end of the list scrolls into view. */
  onLoadMore: () => void;
  /** Opens the dialog of the wallpaper with this id. */
  onOpen: (id: string) => void;
  /** The order of the list; the table picks it from its column headings, the grid by name. */
  sort: Sort | null;
  /** Sets the order of the list. */
  onSort: (sort: Sort) => void;
}

/** A card's picture, with a skeleton until it is there. */
function Picture({ wall, name }: { wall: Wall; name: string }) {
  const [loaded, setLoaded] = useState(false);

  return (
    <span className={s.frame}>
      {!loaded && <Skeleton variant="image" className={s.placeholder} />}
      <img
        className={s.image}
        src={wall.url}
        alt={name}
        loading="lazy"
        decoding="async"
        data-loaded={loaded || undefined}
        onLoad={() => setLoaded(true)}
        // A broken picture still ends the skeleton rather than pulsing forever.
        onError={() => setLoaded(true)}
      />
    </span>
  );
}

/** One wallpaper of the grid: its picture, name and source, and a star in its corner. */
function WallCard({ id, wall }: { id: string; wall: Wall }) {
  const [favorites, toggleFavorite] = useAtom(favoritesAtom);
  const name = nameOf(wall.path);

  return (
    <GridListItem id={id} textValue={name} className={s.card}>
      {/* The virtualizer reuses a scrolled-out card for the next wallpaper. The key gives the new
          one a fresh picture and skeleton instead of the old picture until the new one loads. */}
      <Picture key={wall.url} wall={wall} name={name} />
      <span className={s.caption}>
        <span className={s.name} title={wall.path}>
          {name}
        </span>
        <Pill>{wall.source}</Pill>
      </span>
      <span className={s.corner}>
        <Star
          variant="overlay"
          aria-label="Favorite"
          isSelected={favorites.has(id)}
          onChange={() => toggleFavorite(id)}
        />
      </span>
    </GridListItem>
  );
}

/**
 * The wallpapers as cards, a fixed number per row for each window class. Only the rows in view are
 * rendered, their pictures load lazily, and a progress circle ends the list while more remain.
 */
export function WallGrid({
  walls,
  hasMore,
  onLoadMore,
  onOpen,
}: WallViewProps) {
  const columns = useSyncExternalStore(subscribe, cardsPerRow);

  return (
    <Virtualizer
      layout={GridLayout}
      layoutOptions={{
        minItemSize: MIN_CARD,
        minSpace: GAP,
        maxColumns: columns,
        loaderHeight: gallery.loaderHeight,
      }}
    >
      <GridList
        aria-label="Wallpapers"
        data-testid="wall-grid"
        className={s.grid}
        layout="grid"
        // Arrows move between the cards; Tab reaches the star of the focused one.
        keyboardNavigationBehavior="tab"
        onAction={(key) => onOpen(String(key))}
      >
        {/* `Collection` keys each element by its `id` prop; without one it keys by position, and a
            new filter would then hand an item a different id. */}
        <Collection items={walls}>
          {(wall) => <WallCard id={wallId(wall)} wall={wall} />}
        </Collection>
        {/* Loads once in view, not a viewport ahead, so the circle shows at the end of a batch. */}
        <GridListLoadMoreItem
          className={s.loader}
          isLoading={hasMore}
          onLoadMore={hasMore ? onLoadMore : undefined}
          scrollOffset={0}
        >
          <ProgressCircle aria-label="Loading more wallpapers" />
        </GridListLoadMoreItem>
      </GridList>
    </Virtualizer>
  );
}
