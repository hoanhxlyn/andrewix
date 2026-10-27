import { useAtom, useAtomValue } from "jotai";
import { useMemo, useState } from "react";
import { Outlet, useNavigate } from "react-router";
import { favoritesAtom } from "@/atoms/favorites";
import { wallsLayoutAtom } from "@/atoms/walls";
import { WallGrid } from "@/components/Walls/WallGrid";
import { WallTable } from "@/components/Walls/WallTable";
import { SORTS, SOURCES, WALL_LAYOUTS } from "@/constants";
import { sorted } from "@/helper/sort-walls";
import { ALL, wallHref, wallId } from "@/helper/wallpapers";
import { serialize, useWallsState } from "@/hooks/use-walls-state";
import { gallery } from "@/styles/tokens.css";
import {
  Button,
  EmptyState,
  Icons,
  Menu,
  MenuItem,
  MenuTrigger,
  SearchField,
  Segment,
  SegmentedButton,
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

/** Searchable gallery of the wallpapers the repository's hosts can use, as cards or as rows. */
export default function Walls() {
  const [{ search, source, sort, favorites: onlyFavorites }, setParams] =
    useWallsState();
  const favorites = useAtomValue(favoritesAtom);
  const query = search ?? "";
  const active = source ?? "all";
  const order = sort ?? "default";
  const SortIcon = ORDER_ICONS[order];
  const [layout, setLayout] = useAtom(wallsLayoutAtom);
  const navigate = useNavigate();

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

  // The filter and order as a query string. It rides along to the dialog route, so that route has
  // it in its own URL, and a new one starts the list again from its first batch.
  const filter = serialize({ search, source, sort, favorites: onlyFavorites });
  const [batch, setBatch] = useState<{ filter: string; size: number }>({
    filter,
    size: gallery.batchSize,
  });
  const size = batch.filter === filter ? batch.size : gallery.batchSize;
  const loaded = useMemo(() => shown.slice(0, size), [shown, size]);
  const loadMore = () => setBatch({ filter, size: size + gallery.batchSize });

  const open = (id: string) => {
    const wall = shown.find((other) => wallId(other) === id);
    if (wall !== undefined) navigate(wallHref(wall) + filter);
  };
  const View = layout === "table" ? WallTable : WallGrid;

  return (
    <div className={s.layout}>
      <div className={s.toolbar}>
        <div className={s.actions}>
          <SearchField
            className={s.search}
            value={query}
            onChange={(value) =>
              setParams({ search: value || null }, { history: "replace" })
            }
            placeholder="Search"
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
          <SegmentedButton
            aria-label="Layout"
            className={s.layoutSwitch}
            selectionMode="single"
            disallowEmptySelection
            selectedKeys={[layout]}
            onSelectionChange={(keys) => {
              const [key] = [...keys];
              const picked = WALL_LAYOUTS.find((name) => name === key);
              if (picked !== undefined) setLayout(picked);
            }}
          >
            <Segment id="grid" aria-label="Grid" icon={<Icons.Grid />} />
            <Segment id="table" aria-label="Table" icon={<Icons.Table />} />
          </SegmentedButton>
        </div>
        <div className={s.filters}>
          {/* A filter chip of its own: it narrows any source, so it is not one of their choices. */}
          <TagGroup
            aria-label="Favorites filter"
            className={s.favorites}
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
      </div>
      {shown.length === 0 && onlyFavorites && favorites.size === 0 ? (
        <EmptyState icon={<Icons.NotFavorite />}>
          No favorite yet. Star a wallpaper to keep it here.
        </EmptyState>
      ) : shown.length === 0 ? (
        <EmptyState icon={<Icons.Search />}>No wallpaper matches.</EmptyState>
      ) : (
        <View
          // A new filter or order shows its list from the top, rather than at the old scroll
          // position, where the end of its first batch could already be in view.
          key={filter}
          walls={loaded}
          hasMore={loaded.length < shown.length}
          onLoadMore={loadMore}
          onOpen={open}
        />
      )}
      {/* The dialog of one wallpaper, over this gallery. Empty unless that route is open. */}
      <Outlet />
    </div>
  );
}
