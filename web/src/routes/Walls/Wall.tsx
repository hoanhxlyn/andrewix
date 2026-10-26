import { useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router";
import { ALL, nameOf } from "@/helper/wallpapers";
import { Badge, Button, Icons, Modal, Skeleton } from "@/ui";
import * as s from "./Wall.css";

/** One wallpaper as a dialog over the grid, addressed by its own route. */
export default function Wall() {
  const { id = "" } = useParams();
  const navigate = useNavigate();
  const [isOpen, setOpen] = useState(true);
  const [loaded, setLoaded] = useState(false);
  const wall = ALL.find((other) => `${other.source}/${other.path}` === id);
  // Back to the grid with the filter it was opened from, which the dialog route carries along.
  const { search } = useLocation();

  if (wall === undefined) {
    return null;
  }

  return (
    <Modal
      aria-label={nameOf(wall.path)}
      className={s.modal}
      isOpen={isOpen}
      onOpenChange={setOpen}
      // The route only goes away once the closing animation has played.
      onClosed={() => navigate(`/walls${search}`)}
    >
      <header className={s.header}>
        <span className={s.name} title={wall.path}>
          {wall.path}
        </span>
        <Badge>{wall.source}</Badge>
        <Button
          variant="icon"
          icon={<Icons.Close />}
          aria-label="Close"
          onPress={() => setOpen(false)}
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
          onLoad={() => setLoaded(true)}
          onError={() => setLoaded(true)}
        />
      </span>
    </Modal>
  );
}
