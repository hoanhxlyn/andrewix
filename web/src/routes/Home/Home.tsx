import { tree } from "virtual:repo-tree";
import { parseAsBoolean, parseAsString, useQueryStates } from "nuqs";
import { breakpoints } from "@/styles/tokens.css";
import { Button } from "@/ui/Button";
import { Card } from "@/ui/Card";
import { CodePeek } from "@/ui/CodePeek";
import { FolderTree } from "@/ui/FolderTree";
import { SearchField } from "@/ui/SearchField";
import ExpandIcon from "~icons/mdi/menu";
import CollapseIcon from "~icons/mdi/menu-open";
import * as s from "./Home.css";

/** The repository config as a sidebar tree beside the source of the selected file. */
export default function Home() {
  // `file` and `search` share the page through the URL; `tree` is the sidebar toggle.
  const [{ file, search, tree: treeShown }, setParams] = useQueryStates({
    file: parseAsString,
    search: parseAsString,
    tree: parseAsBoolean.withDefault(true),
  });

  return (
    <Card variant="elevated" className={s.layout}>
      <aside className={treeShown ? s.pane : s.rail}>
        <div className={s.bar}>
          <Button
            variant="icon"
            icon={treeShown ? <CollapseIcon /> : <ExpandIcon />}
            aria-label={treeShown ? "Hide the tree" : "Show the tree"}
            aria-expanded={treeShown}
            onPress={() => setParams({ tree: !treeShown })}
          />
          {treeShown && (
            <SearchField
              className={s.search}
              value={search ?? ""}
              onChange={(value) =>
                setParams({ search: value || null }, { history: "replace" })
              }
              placeholder="Search files"
            />
          )}
        </div>
        {treeShown && (
          <div className={s.scroller}>
            <FolderTree
              tree={tree}
              selected={file}
              query={search ?? ""}
              onSelect={(path) =>
                setParams({
                  file: path,
                  // A picked file hides the overlay drawer on compact; desktop keeps the sidebar.
                  tree: window.matchMedia(breakpoints.medium).matches
                    ? treeShown
                    : false,
                })
              }
            />
          </div>
        )}
      </aside>
      <CodePeek className={s.peek} path={file} />
    </Card>
  );
}
