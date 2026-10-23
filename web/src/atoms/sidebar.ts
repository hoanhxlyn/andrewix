import { atomWithStorage } from "jotai/utils";
import { sidebarWidth } from "@/styles/tokens.css";

// Width of the tree sidebar in pixels, as last dragged. Remembered per browser, not in the URL:
// it fits one screen rather than describing what a shared link shows.
export const sidebarWidthAtom = atomWithStorage<number>(
  "sidebar-width",
  sidebarWidth.initial,
  undefined,
  { getOnInit: true },
);

// Whether the tree sidebar is shown, remembered per browser for the same reason.
export const sidebarShownAtom = atomWithStorage<boolean>(
  "sidebar-shown",
  true,
  undefined,
  { getOnInit: true },
);
