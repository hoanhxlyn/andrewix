import { WALL_LAYOUTS, type WallLayout } from "@/constants";
import { atomWithSetting } from "./settings";

const isLayout = (value: unknown): value is WallLayout =>
  WALL_LAYOUTS.some((layout) => layout === value);

// How the gallery lays out its wallpapers, remembered per browser like the sidebar: it suits one
// screen and one person rather than describing what a shared link shows.
export const wallsLayoutAtom = atomWithSetting<WallLayout>(
  "walls-layout",
  "grid",
  isLayout,
);
