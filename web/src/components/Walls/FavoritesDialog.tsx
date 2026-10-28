import { useAtom, useAtomValue, useSetAtom } from "jotai";
import { useState } from "react";
import { FileTrigger } from "react-aria-components/FileTrigger";
import {
  favoritesAtom,
  importFavoritesAtom,
  lastExportAtom,
} from "@/atoms/favorites";
import { favoritesDialogAtom } from "@/atoms/walls";
import {
  favoriteFileName,
  readFavoriteFile,
  serializeFavorites,
} from "@/helper/favorites";
import {
  Button,
  Icons,
  Modal,
  notify,
  Segment,
  SegmentedButton,
  TextField,
} from "@/ui";
import * as s from "./FavoritesDialog.css";

/** Name the export offers first; anyone can type their own before saving. */
const DEFAULT_NAME = "My Favorite Themes";

/** Dialog that writes the favorites to a file and reads another browser's back. */
export function FavoritesDialog() {
  const [isOpen, setOpen] = useAtom(favoritesDialogAtom);
  const favorites = useAtomValue(favoritesAtom);
  const importFavorites = useSetAtom(importFavoritesAtom);
  const [lastExport, setLastExport] = useAtom(lastExportAtom);
  const [name, setName] = useState(DEFAULT_NAME);
  const [file, setFile] = useState<ReadonlySet<string> | null>(null);
  const [error, setError] = useState(false);
  const [replace, setReplace] = useState(false);

  const close = () => {
    setFile(null);
    setError(false);
    setReplace(false);
    setOpen(false);
  };

  const pick = async (files: FileList | null) => {
    const picked = files?.[0];
    if (picked === undefined) return;
    const ids = readFavoriteFile(await picked.text());
    setFile(ids);
    setError(ids === null);
  };

  const added =
    file === null ? 0 : [...file].filter((id) => !favorites.has(id)).length;
  const total = replace ? (file?.size ?? 0) : favorites.size + added;
  // How many of the stars this browser holds the file does not, so an overwrite can say what it
  // takes away rather than only what it leaves.
  const dropped =
    file === null ? 0 : [...favorites].filter((id) => !file.has(id)).length;

  const apply = () => {
    if (file === null) return;
    importFavorites({ ids: file, replace });
    close();
    notify({
      title: "Favorites imported",
      description: `${total} starred in this browser.`,
    });
  };

  const exportFavorites = () => {
    download(favorites, favoriteFileName(name));
    setLastExport({ at: Date.now(), count: favorites.size });
  };

  /** What picking the file would change, in the mode the segments are set to. */
  const preview = (): string => {
    if (file === null) return "";
    if (replace) {
      const overwrite = `Overwrites your ${favorites.size} with ${file.size}`;
      return dropped === 0
        ? `${overwrite}.`
        : `${overwrite}: ${dropped} dropped.`;
    }
    return added === 0
      ? "Nothing new: every wallpaper in the file is already starred."
      : `Adds ${added}, for ${total} starred in this browser.`;
  };

  return (
    <Modal
      aria-label="Favorites"
      className={s.modal}
      isOpen={isOpen}
      onOpenChange={(open) => (open ? setOpen(true) : close())}
    >
      <header className={s.header}>
        <h2 className={s.title}>Favorites</h2>
        <Button
          variant="icon"
          icon={<Icons.Close />}
          aria-label="Close"
          onPress={close}
        />
      </header>
      <div className={s.body}>
        <TextField
          label="File name"
          value={name}
          onChange={setName}
          isDisabled={favorites.size === 0}
        />
        <div className={s.actions}>
          <Button
            variant="tonal"
            icon={<Icons.JsonFile />}
            isDisabled={favorites.size === 0}
            onPress={exportFavorites}
          >
            {`Export (${favorites.size})`}
          </Button>
          <FileTrigger
            acceptedFileTypes={[".json"]}
            onSelect={(files) => void pick(files)}
          >
            <Button variant="outlined" icon={<Icons.File />}>
              Choose file
            </Button>
          </FileTrigger>
        </div>
        <p className={s.line}>{lastExported(lastExport)}</p>
        {error && <p className={s.error}>Not a favorites file.</p>}
        {file !== null && (
          <>
            <SegmentedButton
              aria-label="How to import"
              className={s.modes}
              selectionMode="single"
              disallowEmptySelection
              selectedKeys={[replace ? "replace" : "merge"]}
              onSelectionChange={(keys) => setReplace(keys.has("replace"))}
            >
              <Segment id="merge">Merge</Segment>
              <Segment id="replace">Overwrite</Segment>
            </SegmentedButton>
            <p className={s.line}>{preview()}</p>
          </>
        )}
      </div>
      {/* Nothing to apply until a file is picked, so the dialog ends at its buttons until then. */}
      {file !== null && (
        <footer className={s.footer}>
          <Button variant="text" onPress={close}>
            Cancel
          </Button>
          <Button onPress={apply}>Import</Button>
        </footer>
      )}
    </Modal>
  );
}

/** When the file someone holds was written, so they know how out of date it is. */
function lastExported(last: { at: number; count: number } | null): string {
  if (last === null) return "Not exported yet.";
  const when = new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(last.at));
  const favorite = last.count === 1 ? "favorite" : "favorites";
  return `Last exported ${when}, ${last.count} ${favorite}.`;
}

/** Downloads the favorites under this file name, as the file an import reads back. */
function download(favorites: ReadonlySet<string>, name: string): void {
  const url = URL.createObjectURL(
    new Blob([serializeFavorites(favorites)], { type: "application/json" }),
  );
  const link = document.createElement("a");
  link.href = url;
  link.download = name;
  document.body.append(link);
  link.click();
  link.remove();
  // Both browsers start the download from the press, but not before it returns.
  setTimeout(() => URL.revokeObjectURL(url), 0);
}
