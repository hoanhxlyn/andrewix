import { type Wall, walls } from "@/data/walls";
import { imagePaths, imageUrlOf } from "@/helper/config-files";

/** Local backgrounds ship inside the app, since they are files of this repository. */
const LOCAL = "config/background/";

const local: Wall[] = imagePaths
  .filter((path) => path.startsWith(LOCAL))
  .flatMap((path) => {
    const url = imageUrlOf(path);
    return url === null
      ? []
      : [{ source: "local", path: path.slice(LOCAL.length), url }];
  });

/** One wallpaper, as generated from the flake inputs. */
export type { Wall } from "@/data/walls";

/** Every wallpaper the hosts can pick: local files and the two flake inputs. */
export const ALL: readonly Wall[] = [...local, ...walls];

/** Route of one wallpaper's dialog, showing it over the grid. */
export const wallHref = (wall: Wall): string =>
  `/walls/${encodeURIComponent(`${wall.source}/${wall.path}`)}`;

/** Name of a wallpaper, the last segment of its path. */
export const nameOf = (path: string): string =>
  path.slice(path.lastIndexOf("/") + 1);
