import { useAtom } from "jotai";
import { useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router";
import { favoritesAtom } from "@/atoms/favorites";
import { ALL, nameOf, wallId } from "@/helper/wallpapers";
import { Badge, Button, Icons, Modal, Skeleton } from "@/ui";
import { Star } from "./Star";
import * as s from "./Wall.css";

/** One wallpaper as a dialog over the grid, addressed by its own route. */
export default function Wall() {
  const { id = "" } = useParams();
  const navigate = useNavigate();
  // `search` leads back to the grid with the filter the dialog was opened from. The dialog is
  // closed for one history entry, not for the component: a card pressed again before the grid's
  // own render lands keeps this component mounted, and must still open a dialog.
  const { key, search } = useLocation();
  const [closedAt, setClosedAt] = useState<string | null>(null);
  const isOpen = closedAt !== key;
  // Per picture too, so another wallpaper shown in the same dialog gets its skeleton back.
  const [loadedUrl, setLoadedUrl] = useState<string | null>(null);
  const [favorites, toggleFavorite] = useAtom(favoritesAtom);
  const wall = ALL.find((other) => wallId(other) === id);

  if (wall === undefined) {
    return null;
  }
  const loaded = loadedUrl === wall.url;

  return (
    <Modal
      aria-label={nameOf(wall.path)}
      className={s.modal}
      isOpen={isOpen}
      onOpenChange={(open) => setClosedAt(open ? null : key)}
      // The route only goes away once the closing animation has played.
      onClosed={() => navigate(`/walls${search}`)}
    >
      {/* Close leads and the action trails, as in a Material full-screen dialog. */}
      <header className={s.header}>
        <Button
          variant="icon"
          icon={<Icons.Close />}
          aria-label="Close"
          onPress={() => setClosedAt(key)}
        />
        <span className={s.name} title={wall.path}>
          {wall.path}
        </span>
        <Badge>{wall.source}</Badge>
        <Star
          aria-label="Favorite"
          isSelected={favorites.has(id)}
          onChange={() => toggleFavorite(id)}
        />
      </header>
      <span className={s.frame}>
        {!loaded && <Skeleton variant="image" className={s.placeholder} />}
        <img
          className={s.image}
          src={wall.url}
          alt={nameOf(wall.path)}
          decoding="async"
          data-loaded={loaded || undefined}
          onLoad={() => setLoadedUrl(wall.url)}
          onError={() => setLoadedUrl(wall.url)}
        />
      </span>
    </Modal>
  );
}
