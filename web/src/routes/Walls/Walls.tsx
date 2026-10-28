import { useAtom, useAtomValue, useSetAtom } from "jotai";
import { useMemo, useState } from "react";
import { Outlet, useNavigate } from "react-router";
import { favoritesAtom } from "@/atoms/favorites";
import { favoritesDialogAtom, wallsLayoutAtom } from "@/atoms/walls";
import { FavoritesDialog } from "@/components/Walls/FavoritesDialog";
import { WallGrid } from "@/components/Walls/WallGrid";
import { WallTable } from "@/components/Walls/WallTable";
import type { Sort } from "@/constants";
import { SORT_ORDERS, SOURCES, WALL_LAYOUTS } from "@/constants";
import { sorted, withoutExtension } from "@/helper/sort-walls";
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
  catppuccin: "Catppuccin",
  gruvbox: "Gruvbox",
  tokyonight: "Tokyo Night",
};

/** The one chip of the favorites filter, beside the source chips. */
const FAVORITES_CHIP = [{ id: "favorites" }] as const;

const ORDERS = ["default", ...SORT_ORDERS] as const;

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
  const [
    { search, source, sort: column, dir, favorites: onlyFavorites },
    setParams,
  ] = useWallsState();
  const favorites = useAtomValue(favoritesAtom);
  const query = search ?? "";
  const active = source ?? "all";
  const sort = useMemo<Sort | null>(
    () => (column === null || dir === null ? null : { column, order: dir }),
    [column, dir],
  );
  const order = sort?.column === "name" ? sort.order : null;
  const SortIcon = ORDER_ICONS[order ?? "default"];
  const [layout, setLayout] = useAtom(wallsLayoutAtom);
  const openFavorites = useSetAtom(favoritesDialogAtom);
  const navigate = useNavigate();

  // The grid's toolbar offers name orders only, so a column order picked in the table is the
  // table's; the grid keeps the order of its sources until a name order is picked.
  const appliedSort = layout === "table" || order !== null ? sort : null;

  const shown = useMemo(() => {
    const needle = query.trim().toLowerCase();
    const matching = ALL.filter(
      (wall) =>
        (active === "all" || wall.source === active) &&
        (needle === "" ||
          withoutExtension(wall.path).toLowerCase().includes(needle)) &&
        (!onlyFavorites || favorites.has(wallId(wall))),
    );
    return sorted(matching, appliedSort, favorites);
  }, [query, active, appliedSort, onlyFavorites, favorites]);

  // The filter and order as a query string. It rides along to the dialog route, so that route has
  // it in its own URL, and a new one starts the list again from its first batch.
  const filter = serialize({
    search,
    source,
    sort: column,
    dir,
    favorites: onlyFavorites,
  });
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
          {/* The table sorts from its column headings, so the name order is the grid's alone. */}
          {layout === "grid" && (
            <MenuTrigger>
              <Button
                variant="icon"
                icon={<SortIcon />}
                aria-label={`Sort by name: ${ORDER_LABELS[order ?? "default"]}`}
              />
              <Menu
                aria-label="Sort by name"
                selectionMode="single"
                disallowEmptySelection
                selectedKeys={[order ?? "default"]}
                onSelectionChange={(keys) => {
                  const [key] = [...keys];
                  const picked = SORT_ORDERS.find((name) => name === key);
                  setParams(
                    {
                      sort: picked === undefined ? null : "name",
                      dir: picked ?? null,
                    },
                    { history: "replace" },
                  );
                }}
              >
                {ORDERS.map((id) => (
                  <MenuItem key={id} id={id}>
                    {ORDER_LABELS[id]}
                  </MenuItem>
                ))}
              </Menu>
            </MenuTrigger>
          )}
          <Button
            variant="icon"
            icon={<Icons.ImportExport />}
            aria-label="Export and import favorites"
            onPress={() => openFavorites(true)}
          />
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
          sort={sort}
          onSort={(next) =>
            setParams(
              { sort: next.column, dir: next.order },
              { history: "replace" },
            )
          }
        />
      )}
      {/* The dialog of one wallpaper, over this gallery. Empty unless that route is open. */}
      <Outlet />
      <FavoritesDialog />
    </div>
  );
}
