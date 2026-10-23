import { tree } from "virtual:repo-tree";
import { assignInlineVars } from "@vanilla-extract/dynamic";
import { useAtom } from "jotai";
import {
  createSerializer,
  parseAsString,
  type UrlKeys,
  useQueryStates,
} from "nuqs";
import { useId } from "react";
import { clamp } from "remeda";
import { openFilesAtom, wrapLinesAtom } from "@/atoms/code-peek";
import { sidebarShownAtom, sidebarWidthAtom } from "@/atoms/sidebar";
import { breakpoints, sidebarWidth } from "@/styles/tokens.css";
import { Button } from "@/ui/Button";
import { Card } from "@/ui/Card";
import { Checkbox } from "@/ui/Checkbox";
import { CodePeek } from "@/ui/CodePeek";
import { EmptyState } from "@/ui/EmptyState";
import { FolderTree, filePaths } from "@/ui/FolderTree";
import Icons from "@/ui/Icon";
import { SearchField } from "@/ui/SearchField";
import { Splitter } from "@/ui/Splitter";
import { Tab, TabList, TabPanel, Tabs } from "@/ui/Tabs";
import * as s from "./Home.css";

// `file` and `search` share the page through the URL. The open tabs, the sidebar toggle and the
// line wrapping are kept per browser in atoms.
const params = {
  file: parseAsString,
  search: parseAsString,
};

/** One-letter keys keep the URL short; the code keeps the descriptive names. */
const urlKeys: UrlKeys<typeof params> = {
  file: "f",
  search: "q",
};

const serialize = createSerializer(params, { urlKeys });

/** URL of one file on its own, where a link opened in a new tab lands. */
const hrefOf = (path: string) => serialize({ file: path });

/** Every file of the repository tree, the only paths that can be open. */
const FILES = new Set(filePaths(tree, ""));

const nameOf = (path: string) => path.slice(path.lastIndexOf("/") + 1);

/** Pill label of an open file: its name, with its folder when another open file shares the name. */
function labelOf(path: string, open: readonly string[]): string {
  const name = nameOf(path);
  const shared = open.filter((other) => nameOf(other) === name).length > 1;
  return shared ? path.split("/").slice(-2).join("/") : name;
}

/** The repository config as a sidebar tree beside the source of the selected file. */
export default function Home() {
  const [{ file, search }, setParams] = useQueryStates(params, { urlKeys });
  const [storedFiles, setOpenFiles] = useAtom(openFilesAtom);
  const [storedShown, setTreeShown] = useAtom(sidebarShownAtom);
  const [storedWrap, setWrap] = useAtom(wrapLinesAtom);
  // Storage is editable by hand, so stored values are only trusted in the shape they are written.
  const treeShown = storedShown !== false;
  const wrap = storedWrap === true;
  // Stored tabs or a link may repeat a file or name one the repository no longer has; pills need
  // unique, existing paths. A file opened from a link also shows as a pill.
  const open = [
    ...new Set([
      ...(Array.isArray(storedFiles) ? storedFiles : []),
      ...(file === null ? [] : [file]),
    ]),
  ].filter((path) => FILES.has(path));
  const withOpened = (path: string) =>
    open.includes(path) ? open : [...open, path];

  const paneId = useId();
  const [stored, setWidth] = useAtom(sidebarWidthAtom);
  // Storage is editable by hand, so a stored width is only trusted once it is a number in range.
  const width = Number.isFinite(stored)
    ? clamp(stored, sidebarWidth)
    : sidebarWidth.initial;

  const close = (path: string) => {
    const rest = open.filter((other) => other !== path);
    // Closing the shown file shows its right neighbour, else the new last one.
    const next =
      path === file ? (rest[open.indexOf(path)] ?? rest.at(-1) ?? null) : file;
    setOpenFiles(rest);
    setParams({ file: next });
  };

  return (
    <Card variant="elevated" className={s.layout}>
      {/* Hidden rather than unmounted, so the sidebar can slide out and back in. */}
      <aside
        id={paneId}
        className={[s.pane, !treeShown && s.paneHidden]
          .filter(Boolean)
          .join(" ")}
        style={assignInlineVars({ [s.sidebarWidth]: `${width}px` })}
      >
        <SearchField
          value={search ?? ""}
          onChange={(value) =>
            setParams({ search: value || null }, { history: "replace" })
          }
          placeholder="Search files"
        />
        <div className={s.scroller}>
          <FolderTree
            tree={tree}
            selected={file}
            query={search ?? ""}
            onSelect={(path) => {
              setOpenFiles(withOpened(path));
              setParams({ file: path });
              // A picked file hides the overlay drawer on compact; desktop keeps the sidebar.
              if (!window.matchMedia(breakpoints.medium).matches) {
                setTreeShown(false);
              }
            }}
          />
        </div>
      </aside>
      {treeShown && (
        <Splitter
          className={s.splitter}
          aria-label="Resize the tree"
          aria-controls={paneId}
          value={width}
          min={sidebarWidth.min}
          max={sidebarWidth.max}
          step={sidebarWidth.step}
          resetValue={sidebarWidth.initial}
          onChange={setWidth}
        />
      )}
      {/* No tab has the empty key, so with no file none is selected; an absent key would let
          React Aria pick the first tab on its own, out of step with the URL. Arrow keys only move
          focus, Enter or Space opens the file: each opened file loads and highlights its source. */}
      <Tabs
        className={s.peek}
        keyboardActivation="manual"
        selectedKey={file ?? ""}
        onSelectionChange={(key) => setParams({ file: String(key) })}
      >
        <div className={s.bar}>
          <Button
            variant="icon"
            icon={treeShown ? <Icons.Collapse /> : <Icons.Expand />}
            aria-label={treeShown ? "Hide the tree" : "Show the tree"}
            aria-expanded={treeShown}
            onPress={() => setTreeShown(!treeShown)}
          />
          <span className={s.title}>{file}</span>
          <Checkbox isSelected={wrap} onChange={setWrap}>
            wrap
          </Checkbox>
        </div>
        {/* A row of their own under the bar, apart from the toggle and the view options. */}
        <div className={s.tabRow}>
          <TabList
            aria-label="Open files"
            items={open.map((path) => ({ id: path }))}
          >
            {({ id }) => (
              <Tab id={id} tooltip={id} onClose={() => close(id)}>
                {labelOf(id, open)}
              </Tab>
            )}
          </TabList>
        </div>
        {/* Inside the panel, the source is left out of the hidden copy React Aria renders of the
            tabs. Every file of the repository has a tab; any other path has no panel to show in. */}
        {file === null ? (
          <EmptyState>Pick a file in the tree.</EmptyState>
        ) : FILES.has(file) ? (
          <TabPanel id={file}>
            <CodePeek
              path={file}
              wrap={wrap}
              hrefOf={hrefOf}
              // Following a link is a step the back button undoes, unlike picking in the tree.
              onOpen={(path) => {
                setOpenFiles(withOpened(path));
                setParams({ file: path }, { history: "push" });
              }}
            />
          </TabPanel>
        ) : (
          <EmptyState>Not a file of the config.</EmptyState>
        )}
      </Tabs>
    </Card>
  );
}
