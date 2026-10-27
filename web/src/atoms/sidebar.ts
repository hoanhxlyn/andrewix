import { isBoolean } from "remeda";
import { sidebarWidth } from "@/styles/tokens.css";
import { atomWithSetting } from "./settings";

const isWidth = (value: unknown): value is number =>
  Number.isFinite(value) &&
  (value as number) >= sidebarWidth.min &&
  (value as number) <= sidebarWidth.max;

// Width of the tree sidebar in pixels, as last dragged. Remembered per browser, not in the URL:
// it fits one screen rather than describing what a shared link shows.
export const sidebarWidthAtom = atomWithSetting<number>(
  "sidebar-width",
  sidebarWidth.initial,
  isWidth,
);

// Whether the tree sidebar is shown, remembered per browser for the same reason.
export const sidebarShownAtom = atomWithSetting<boolean>(
  "sidebar-shown",
  true,
  isBoolean,
);
