import { useState } from "react";
import { imageUrlOf } from "@/helper/config-files";
import { EmptyState } from "@/ui/EmptyState";
import Icons from "@/ui/Icon";
import * as s from "./ImagePeek.css";

interface ImagePeekProps {
  /** Repository path of the image to show. */
  path: string;
  className?: string;
}

/** Shows one repository image, fitted to the pane. */
export function ImagePeek({ path, className }: ImagePeekProps) {
  // Keyed by path, so a failure is forgotten once another image is shown.
  const [failed, setFailed] = useState<string | null>(null);
  const url = imageUrlOf(path);

  if (url === null) {
    return (
      <EmptyState icon={<Icons.UnknownFile />} className={className}>
        Not a file of the config.
      </EmptyState>
    );
  }
  if (failed === path) {
    return (
      <EmptyState icon={<Icons.Alert />} className={className}>
        Could not load this image.
      </EmptyState>
    );
  }

  return (
    <div className={[s.frame, className].filter(Boolean).join(" ")}>
      <img
        className={s.image}
        src={url}
        alt={path.slice(path.lastIndexOf("/") + 1)}
        onError={() => setFailed(path)}
      />
    </div>
  );
}
