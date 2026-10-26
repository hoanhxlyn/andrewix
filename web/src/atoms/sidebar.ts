import {
  atomWithStorage,
  createJSONStorage,
  unstable_withStorageValidator as withStorageValidator,
} from "jotai/utils";
import { isBoolean } from "remeda";
import { sidebarWidth } from "@/styles/tokens.css";

// Storage is editable by hand, so a stored value that is not in the shape written reads as the
// initial value instead.
const widthStorage = withStorageValidator(
  (value): value is number =>
    Number.isFinite(value) &&
    (value as number) >= sidebarWidth.min &&
    (value as number) <= sidebarWidth.max,
)(createJSONStorage());

// Width of the tree sidebar in pixels, as last dragged. Remembered per browser, not in the URL:
// it fits one screen rather than describing what a shared link shows.
export const sidebarWidthAtom = atomWithStorage<number>(
  "sidebar-width",
  sidebarWidth.initial,
  widthStorage,
  { getOnInit: true },
);

// Whether the tree sidebar is shown, remembered per browser for the same reason.
export const sidebarShownAtom = atomWithStorage<boolean>(
  "sidebar-shown",
  true,
  withStorageValidator(isBoolean)(createJSONStorage()),
  { getOnInit: true },
);
