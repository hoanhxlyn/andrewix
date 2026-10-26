import autoAnimate from "@formkit/auto-animate";
import { useAtom, useAtomValue } from "jotai";
import { useEffect, useMemo, useRef, useState } from "react";
import { Link, Outlet } from "react-router";
import { favoritesAtom } from "@/atoms/favorites";
import { SORTS, SOURCES } from "@/constants";
import { sorted } from "@/helper/sort-walls";
import { ALL, nameOf, type Wall, wallHref, wallId } from "@/helper/wallpapers";
import { serialize, useWallsState } from "@/hooks/use-walls-state";
import {
  Badge,
  Button,
  Card,
  EmptyState,
  Icons,
  Menu,
  MenuItem,
  MenuTrigger,
  SearchField,
  Skeleton,
  Tag,
  TagGroup,
} from "@/ui";
import { Star } from "./Star";
import * as s from "./Walls.css";

const CHIPS = ["all", ...SOURCES] as const;

const CHIP_ITEMS: readonly { id: (typeof CHIPS)[number] }[] = CHIPS.map(
  (id) => ({
    id,
  }),
);

const LABELS: Record<(typeof CHIPS)[number], string> = {
  all: "All",
  local: "Local",
  gruvbox: "Gruvbox",
  tokyonight: "Tokyo Night",
};

/** The one chip of the favorites filter, beside the source chips. */
const FAVORITES_CHIP = [{ id: "favorites" }] as const;

const ORDERS = ["default", ...SORTS] as const;

const ORDER_LABELS: Record<(typeof ORDERS)[number], string> = {
  default: "Default",
  asc: "A–Z",
  desc: "Z–A",
};

/** Icon of the sort button, showing the order the grid is in. */
const ORDER_ICONS: Record<(typeof ORDERS)[number], typeof Icons.Sort> = {
  default: Icons.Sort,
  asc: Icons.SortAscending,
  desc: Icons.SortDescending,
};

/** Keys that move the focus through the cards instead of scrolling the page. */
const ARROWS = new Set([
  "ArrowRight",
  "ArrowLeft",
  "ArrowDown",
  "ArrowUp",
  "Home",
  "End",
]);

/**
 * Focuses the card the key leads to, one cell or one row away. The column count comes from the
 * cards themselves, so it follows the 4/6-column layout without knowing the breakpoints.
 */
function moveFocus(grid: HTMLElement, key: string): void {
  const cards = [...grid.querySelectorAll<HTMLElement>("a")];
  const from = cards.indexOf(document.activeElement as HTMLElement);
  if (from === -1) return;

  const rects = cards.map((card) => card.getBoundingClientRect());
  const row = rects[from]?.top ?? 0;
  const columns = rects.filter((rect) => Math.abs(rect.top - row) < 1).length;
  const to = {
    ArrowRight: from + 1,
    ArrowLeft: from - 1,
    ArrowDown: from + columns,
    ArrowUp: from - columns,
    Home: 0,
    End: cards.length - 1,
  }[key];
  // Leaving the grid is not a move; the ends of the list and of a row just stay put.
  if (to === undefined || to < 0 || to >= cards.length) return;
  const sideways = key === "ArrowLeft" || key === "ArrowRight";
  if (sideways && Math.abs((rects[to]?.top ?? 0) - row) > 1) return;

  cards[to]?.focus();
}

interface WallCardProps {
  wall: Wall;
  /** Where the card leads: the wallpaper's dialog, carrying the current filter. */
  href: string;
}

/**
 * One wallpaper of the grid, with a skeleton until its picture is there and a star in its corner.
 * The star sits beside the link rather than inside it, since a button cannot live in a link.
 */
function WallCard({ wall, href }: WallCardProps) {
  const [loaded, setLoaded] = useState(false);
  const [favorites, toggleFavorite] = useAtom(favoritesAtom);
  const id = wallId(wall);

  return (
    <div className={s.cell}>
      <Link
        className={s.item}
        to={href}
        // The cards are the only things in the grid the arrows move between, so the arrows are
        // caught here and the grid above stays a plain element with no role of its own.
        onKeyDown={(event) => {
          if (!ARROWS.has(event.key) || event.metaKey || event.ctrlKey) return;
          event.preventDefault();
          const grid = event.currentTarget.parentElement?.parentElement;
          if (grid) moveFocus(grid, event.key);
        }}
      >
        <span className={s.frame}>
          {!loaded && <Skeleton variant="image" className={s.placeholder} />}
          <img
            className={s.image}
            src={wall.url}
            alt={nameOf(wall.path)}
            loading="lazy"
            decoding="async"
            data-loaded={loaded || undefined}
            onLoad={() => setLoaded(true)}
            // A broken picture still ends the skeleton rather than pulsing forever.
            onError={() => setLoaded(true)}
          />
        </span>
        <span className={s.caption}>
          <span className={s.name} title={wall.path}>
            {nameOf(wall.path)}
          </span>
          <Badge>{wall.source}</Badge>
        </span>
      </Link>
      <span className={s.corner}>
        <Star
          variant="overlay"
          aria-label="Favorite"
          isSelected={favorites.has(id)}
          onChange={() => toggleFavorite(id)}
        />
      </span>
    </div>
  );
}

/** Searchable grid of the wallpapers the repository's hosts can use. */
export default function Walls() {
  const [{ search, source, sort, favorites: onlyFavorites }, setParams] =
    useWallsState();
  const favorites = useAtomValue(favoritesAtom);
  const query = search ?? "";
  const active = source ?? "all";
  const order = sort ?? "default";
  const SortIcon = ORDER_ICONS[order];
  const grid = useRef<HTMLDivElement>(null);

  // Cards slide instead of jumping when the filter changes which ones are shown.
  useEffect(() => {
    if (grid.current !== null) autoAnimate(grid.current);
  }, []);

  const shown = useMemo(() => {
    const needle = query.trim().toLowerCase();
    const matching = ALL.filter(
      (wall) =>
        (active === "all" || wall.source === active) &&
        (needle === "" || wall.path.toLowerCase().includes(needle)) &&
        (!onlyFavorites || favorites.has(wallId(wall))),
    );
    return sorted(matching, sort);
  }, [query, active, sort, onlyFavorites, favorites]);

  return (
    <Card variant="elevated" className={s.layout}>
      <div className={s.toolbar}>
        <SearchField
          className={s.search}
          value={query}
          onChange={(value) =>
            setParams({ search: value || null }, { history: "replace" })
          }
          placeholder="Search wallpapers"
          aria-label="Search wallpapers"
        />
        <MenuTrigger>
          <Button
            variant="icon"
            icon={<SortIcon />}
            aria-label={`Sort by name: ${ORDER_LABELS[order]}`}
          />
          <Menu
            aria-label="Sort by name"
            selectionMode="single"
            disallowEmptySelection
            selectedKeys={[order]}
            onSelectionChange={(keys) => {
              const [key] = [...keys];
              const picked = SORTS.find((name) => name === key) ?? null;
              setParams({ sort: picked }, { history: "replace" });
            }}
          >
            {ORDERS.map((id) => (
              <MenuItem key={id} id={id}>
                {ORDER_LABELS[id]}
              </MenuItem>
            ))}
          </Menu>
        </MenuTrigger>
        {/* A filter chip of its own: it narrows any source, so it is not one of their choices. */}
        <TagGroup
          aria-label="Favorites filter"
          items={FAVORITES_CHIP}
          selectionMode="multiple"
          selectedKeys={onlyFavorites ? ["favorites"] : []}
          onSelectionChange={(keys) =>
            setParams(
              { favorites: keys !== "all" && keys.size > 0 ? true : null },
              { history: "replace" },
            )
          }
        >
          {({ id }) => (
            <Tag id={id} icon={<Icons.NotFavorite />}>
              Favorites
            </Tag>
          )}
        </TagGroup>
        <TagGroup
          aria-label="Wallpaper source"
          items={CHIP_ITEMS}
          selectionMode="single"
          disallowEmptySelection
          selectedKeys={[active]}
          onSelectionChange={(keys) => {
            const [key] = [...keys];
            const picked = SOURCES.find((name) => name === key) ?? null;
            setParams({ source: picked }, { history: "replace" });
          }}
        >
          {({ id }) => <Tag id={id}>{LABELS[id]}</Tag>}
        </TagGroup>
      </div>
      {shown.length === 0 && onlyFavorites && favorites.size === 0 ? (
        <EmptyState icon={<Icons.NotFavorite />}>
          No favorite yet. Star a wallpaper to keep it here.
        </EmptyState>
      ) : shown.length === 0 ? (
        <EmptyState icon={<Icons.Search />}>No wallpaper matches.</EmptyState>
      ) : (
        <div className={s.grid} data-testid="wall-grid" ref={grid}>
          {shown.map((wall) => (
            <WallCard
              key={wall.url}
              wall={wall}
              // The filter rides along, so the dialog route has it in its own URL.
              href={
                wallHref(wall) +
                serialize({ search, source, sort, favorites: onlyFavorites })
              }
            />
          ))}
        </div>
      )}
      {/* The dialog of one wallpaper, over this grid. Empty unless that route is open. */}
      <Outlet />
    </Card>
  );
}
