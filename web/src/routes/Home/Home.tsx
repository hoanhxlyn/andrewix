import { tree } from "virtual:repo-tree";
import { assignInlineVars } from "@vanilla-extract/dynamic";
import { useAtom } from "jotai";
import {
  createParser,
  createSerializer,
  parseAsArrayOf,
  parseAsString,
  type UrlKeys,
  useQueryStates,
} from "nuqs";
import { useId } from "react";
import { clamp } from "remeda";
import { sidebarWidthAtom } from "@/atoms/sidebar";
import { breakpoints, sidebarWidth } from "@/styles/tokens.css";
import { Button } from "@/ui/Button";
import { Card } from "@/ui/Card";
import { Checkbox } from "@/ui/Checkbox";
import { CodePeek } from "@/ui/CodePeek";
import { FolderTree, filePaths } from "@/ui/FolderTree";
import Icons from "@/ui/Icon";
import { SearchField } from "@/ui/SearchField";
import { Splitter } from "@/ui/Splitter";
import { Tab, TabList, TabPanel, Tabs } from "@/ui/Tabs";
import * as s from "./Home.css";

/** Boolean written as `1` or `0`, shorter in the URL than nuqs's `true` and `false`. */
const parseAsFlag = createParser({
  parse: (value) => (value === "1" ? true : value === "0" ? false : null),
  serialize: (value: boolean) => (value ? "1" : "0"),
});

// `file` and `search` share the page through the URL, and `buffers` the files opened before it,
// so a shared link keeps its pills; `tree` is the sidebar toggle and `wrap` the line wrapping.
const params = {
  file: parseAsString,
  buffers: parseAsArrayOf(parseAsString).withDefault([]),
  search: parseAsString,
  tree: parseAsFlag.withDefault(true),
  wrap: parseAsFlag.withDefault(false),
};

/** One-letter keys keep the URL short; the code keeps the descriptive names. */
const urlKeys: UrlKeys<typeof params> = {
  file: "f",
  buffers: "b",
  search: "q",
  tree: "t",
  wrap: "w",
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
  const [{ file, buffers, search, tree: treeShown, wrap }, setParams] =
    useQueryStates(params, { urlKeys });
  // A shared or hand-edited link may repeat a file or name one the repository no longer has;
  // pills need unique, existing paths. A link with only a file still shows that file as a pill.
  const open = [
    ...new Set([...buffers, ...(file === null ? [] : [file])]),
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
    setParams({ file: next, buffers: rest.length > 0 ? rest : null });
  };

  const peek = (
    <CodePeek
      path={file}
      wrap={wrap}
      hrefOf={hrefOf}
      // Following a link is a step the back button undoes, unlike picking in the tree.
      onOpen={(path) =>
        setParams(
          { file: path, buffers: withOpened(path) },
          { history: "push" },
        )
      }
    />
  );

  return (
    <Card variant="elevated" className={s.layout}>
      {treeShown && (
        <aside
          id={paneId}
          className={s.pane}
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
              onSelect={(path) =>
                setParams({
                  file: path,
                  buffers: withOpened(path),
                  // A picked file hides the overlay drawer on compact; desktop keeps the sidebar.
                  tree: window.matchMedia(breakpoints.medium).matches
                    ? treeShown
                    : false,
                })
              }
            />
          </div>
        </aside>
      )}
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
            onPress={() => setParams({ tree: !treeShown })}
          />
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
          <Checkbox
            isSelected={wrap}
            onChange={(value) => setParams({ wrap: value || null })}
          >
            wrap
          </Checkbox>
        </div>
        {/* Inside the panel, the source is left out of the hidden copy React Aria renders of the
            tabs. A file without a tab (none picked, or not in the repository) shows only its message. */}
        {file !== null && open.includes(file) ? (
          <TabPanel id={file}>{peek}</TabPanel>
        ) : (
          peek
        )}
      </Tabs>
    </Card>
  );
}
