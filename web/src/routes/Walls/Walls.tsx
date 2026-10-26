import autoAnimate from "@formkit/auto-animate";
import { useEffect, useMemo, useRef, useState } from "react";
import { Link, Outlet } from "react-router";
import { SOURCES } from "@/constants";
import { ALL, nameOf, type Wall, wallHref } from "@/helper/wallpapers";
import { serialize, useWallsState } from "@/hooks/use-walls-state";
import {
  Badge,
  Card,
  EmptyState,
  Icons,
  SearchField,
  Skeleton,
  Tag,
  TagGroup,
} from "@/ui";
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

/** One wallpaper of the grid, with a skeleton until its picture is there. */
function WallCard({ wall, href }: WallCardProps) {
  const [loaded, setLoaded] = useState(false);

  return (
    <Link
      className={s.item}
      to={href}
      // The cards are the only focusable things in the grid, so the arrows are caught here and
      // the grid above stays a plain element with no role of its own.
      onKeyDown={(event) => {
        if (!ARROWS.has(event.key) || event.metaKey || event.ctrlKey) return;
        event.preventDefault();
        const grid = event.currentTarget.parentElement;
        if (grid !== null) moveFocus(grid, event.key);
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
  );
}

/** Searchable grid of the wallpapers the repository's hosts can use. */
export default function Walls() {
  const [{ search, source }, setParams] = useWallsState();
  const query = search ?? "";
  const active = source ?? "all";
  const grid = useRef<HTMLDivElement>(null);

  // Cards slide instead of jumping when the filter changes which ones are shown.
  useEffect(() => {
    if (grid.current !== null) autoAnimate(grid.current);
  }, []);

  const shown = useMemo(() => {
    const needle = query.trim().toLowerCase();
    return ALL.filter(
      (wall) =>
        (active === "all" || wall.source === active) &&
        (needle === "" || wall.path.toLowerCase().includes(needle)),
    );
  }, [query, active]);

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
      {shown.length === 0 ? (
        <EmptyState icon={<Icons.Search />}>No wallpaper matches.</EmptyState>
      ) : (
        <div className={s.grid} data-testid="wall-grid" ref={grid}>
          {shown.map((wall) => (
            <WallCard
              key={wall.url}
              wall={wall}
              // The filter rides along, so the dialog route has it in its own URL.
              href={wallHref(wall) + serialize({ search, source })}
            />
          ))}
        </div>
      )}
      {/* The dialog of one wallpaper, over this grid. Empty unless that route is open. */}
      <Outlet />
    </Card>
  );
}
