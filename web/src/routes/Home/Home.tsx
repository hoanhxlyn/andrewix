import { tree } from "virtual:repo-tree";
import { assignInlineVars } from "@vanilla-extract/dynamic";
import { clsx } from "clsx";
import { useAtom } from "jotai";
import { lazy, Suspense, useId } from "react";
import { markdownPreviewAtom, wrapLinesAtom } from "@/atoms/code-peek";
import { sidebarShownAtom, sidebarWidthAtom } from "@/atoms/sidebar";
import { isImageFile, isMarkdownFile } from "@/helper/config-files";
import { labelOf } from "@/helper/open-files";
import { hrefOf, useHomeState } from "@/hooks/use-home-state";
import { FILES, useOpenFiles } from "@/hooks/use-open-files";
import { breakpoints, sidebarWidth } from "@/styles/tokens.css";
import {
  Button,
  Checkbox,
  CodePeek,
  EmptyState,
  FolderTree,
  Icons,
  ImagePeek,
  SearchField,
  Skeleton,
  Splitter,
  Tab,
  TabList,
  TabPanel,
  Tabs,
} from "@/ui";
import * as s from "./Home.css";

/** Loaded with the first markdown file opened, keeping the renderer out of the page chunk. */
const MarkdownPeek = lazy(() =>
  import("@/ui/MarkdownPeek").then((module) => ({
    default: module.MarkdownPeek,
  })),
);

/** The repository config as a sidebar tree beside the source of the selected file. */
export default function Home() {
  const [{ file, search }, setParams] = useHomeState();
  const { open, select, follow, close } = useOpenFiles();
  const [treeShown, setTreeShown] = useAtom(sidebarShownAtom);
  const [wrap, setWrap] = useAtom(wrapLinesAtom);
  const [preview, setPreview] = useAtom(markdownPreviewAtom);

  const paneId = useId();
  const [width, setWidth] = useAtom(sidebarWidthAtom);

  return (
    <div className={s.layout}>
      {/* Hidden rather than unmounted, so the sidebar can slide out and back in. */}
      <aside
        id={paneId}
        className={clsx(s.pane, !treeShown && s.paneHidden)}
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
              select(path);
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
        onSelectionChange={(key) => select(String(key))}
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
          {file !== null && isMarkdownFile(file) && (
            <Checkbox isSelected={preview} onChange={setPreview}>
              preview
            </Checkbox>
          )}
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
          <EmptyState icon={<Icons.File />}>
            Pick a file in the tree.
          </EmptyState>
        ) : FILES.has(file) ? (
          <TabPanel id={file}>
            {isImageFile(file) ? (
              <ImagePeek path={file} />
            ) : isMarkdownFile(file) && preview ? (
              // The renderer chunk loads behind the same skeleton the file does.
              <Suspense fallback={<Skeleton />}>
                <MarkdownPeek path={file} />
              </Suspense>
            ) : (
              <CodePeek path={file} hrefOf={hrefOf} onOpen={follow} />
            )}
          </TabPanel>
        ) : (
          <EmptyState icon={<Icons.UnknownFile />}>
            Not a file of the config.
          </EmptyState>
        )}
      </Tabs>
    </div>
  );
}
