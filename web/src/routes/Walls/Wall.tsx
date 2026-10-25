import { useEffect, useRef, useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router";
import { ALL, nameOf } from "@/helper/wallpapers";
import { motion } from "@/styles/tokens.css";
import { Badge } from "@/ui/Badge";
import { Button } from "@/ui/Button";
import Icons from "@/ui/Icon";
import { Skeleton } from "@/ui/Skeleton";
import * as s from "./Wall.css";

/** One wallpaper as a dialog over the grid, addressed by its own route. */
export default function Wall() {
  const { id = "" } = useParams();
  const navigate = useNavigate();
  const ref = useRef<HTMLDialogElement>(null);
  const [closing, setClosing] = useState(false);
  const [loaded, setLoaded] = useState(false);
  const wall = ALL.find((other) => `${other.source}/${other.path}` === id);
  // Back to the grid with the filter it was opened from, which the dialog route carries along.
  const { search } = useLocation();

  // The route only goes away once the closing animation has played.
  useEffect(() => {
    if (!closing) return;
    const timer = setTimeout(() => {
      ref.current?.close();
      navigate(`/walls${search}`);
    }, motion.emphasized.duration);
    return () => clearTimeout(timer);
  }, [closing, navigate, search]);

  useEffect(() => {
    ref.current?.showModal();
    return () => ref.current?.close();
  }, []);

  if (wall === undefined) {
    return null;
  }

  return (
    <dialog
      ref={ref}
      className={s.dialog}
      aria-label={nameOf(wall.path)}
      data-closing={closing || undefined}
      // On mousedown, not click: a card's click can land here once the dialog is already open,
      // and that stray click must not close it again.
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) setClosing(true);
      }}
      // Esc would close the dialog at once; play the same animation the backdrop click does.
      onCancel={(event) => {
        event.preventDefault();
        setClosing(true);
      }}
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
          onPress={() => setClosing(true)}
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
    </dialog>
  );
}
