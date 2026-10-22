import tree from "virtual:repo-tree";
import { useState } from "react";
import { CodePeek } from "@/ui/CodePeek";
import { FolderTree } from "@/ui/FolderTree";
import { PanZoom } from "@/ui/PanZoom";
import * as s from "./Map.css";

/** The repository config as a tree beside the source of the selected file. */
export default function MapPage() {
  const [selected, setSelected] = useState<string | null>(null);

  return (
    <div className={s.page}>
      <PanZoom className={s.tree}>
        <FolderTree tree={tree} onSelect={setSelected} />
      </PanZoom>
      <CodePeek className={s.peek} path={selected} />
    </div>
  );
}
