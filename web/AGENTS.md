# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`web/` is a React SPA for viewing flow structures as diagrams. It sits inside the NixOS repo at the root (see `../AGENTS.md` for that), but nothing in `web/` is built by Nix. Run every command below from `web/`.

## Commands

Bun is the runtime and package manager; do not use npm, node or `tsc` (`typescript` is not a dependency).

```bash
bun install
bun run dev        # react-router dev server (bunx --bun)
bun run build      # SPA build into build/client
bun run deploy     # build + deploy to Cloudflare Pages (andrewix.pages.dev)
bun run preview    # serve build/client
bun run walls      # regenerate src/routes/Walls/walls.ts from the wallpaper flake inputs
bun run test       # unit tests (bun test, src/ only, see bunfig.toml)
bun run e2e        # Playwright suite against build/client; needs the nixpkgs browsers from .envrc
bun run review     # CodeRabbit review of this branch against main, with .coderabbit.yaml
bun check          # Bun's built-in type checker
bun run lint       # biome lint --write --unsafe . (rewrites files)
bun run format     # biome format --write .
bunx biome check <file>   # check one file without the --unsafe rewrites
```

Validate a change with `bun check`, `bunx biome check .`, `bun run test` and `bun run build`; run `bun run e2e` too when the change shows in the page.

**Tests.** Unit tests use `bun:test` and live in `src/__test__/`, never beside the file they cover. That folder mirrors the tree of `src/`: the test of `src/helper/sort-walls.ts` is `src/__test__/helper/sort-walls.test.ts`, and it imports the module through the `@/` alias (`@/helper/sort-walls`). `bunfig.toml` sets the test root to `src/`, so `bun test` never loads the Playwright specs in `e2e/`, and Playwright (`testDir: "e2e"`) never loads the unit tests. Bun runs the code without Vite, so a unit-tested module cannot import, even indirectly, `import.meta.glob` (`helper/config-files.ts`, `helper/wallpapers.ts`), a `virtual:` module or a `.css.ts` file. Keep the logic worth testing in a pure helper (`helper/file-kinds.ts`, `helper/open-files.ts`, `helper/sort-walls.ts`, `ui/FolderTree/tree-paths.ts`) and let the hook, route or Vite-only module call it; type-only imports are fine.

## Architecture

**Routing.** React Router v8 framework mode as an SPA (`ssr: false`, `appDirectory: "src"`). Routes are declared in `src/routes.ts`; `layouts/AppShell.tsx` is the layout route and `root.tsx` holds the document shell. `routes/` holds route modules only: each file there is one `routes.ts` points at, plus its `.css.ts`. Data and helpers live in `src/helper/` (generated data in `src/data/`). A page's URL state (nuqs params, URL keys, serializer) and its actions live in a hook in `src/hooks/` (`use-home-state.ts`, `use-open-files.ts`, `use-walls-state.ts`), not in the route file. Route files are flat until a route needs its `.css.ts` or a child route; then they share a folder: `routes/<Name>/<Name>.tsx`, with no barrel because `routes.ts` imports each file by path. A component is never a route, even when only one page uses it: components of one page go in `components/<Page>/` (`components/Walls/WallGrid.tsx`), imported by path with no barrel, and reusable primitives go in `ui/`.

**Styling is vanilla-extract, split across a few files that only make sense together:**

- `styles/tokens.css.ts`: the single source of design tokens. `vars` merges `themeVars` (values that differ in light and dark: `color`, `elevation`) with the shared tokens (`space`, `shape`, `type`, `motion`, ...). Shared tokens never go inside `light`/`dark`. `light`'s shape is the contract `dark` must satisfy. Colors come from `@catppuccin/palette`, mapped to Material 3 roles. `breakpoints` are plain strings because media queries cannot read CSS variables. `text` is a plain object of typography properties to spread into styles.
- `styles/global.css.ts`: applies the themes (`createGlobalTheme` on `:root[data-theme=...]` and nested `[data-theme=...]`, so a subtree can force a theme), the per-breakpoint layout variables, and element defaults.
- `styles/layers.css.ts`: cascade order `base` < `components` < `utilities`, plus the `inBase` and `inComponents` wrappers. It also holds `stateLayer`, the hover, focus and pressed feedback with focus ring that interactive components compose. Sprinkles are the `utilities` layer, so they beat component rules. Unlayered CSS beats every layer; `routes/*.css.ts` are intentionally unlayered.
- `styles/sprinkles.css.ts`: the utility allowlist. Only the listed properties and values exist, and values come from tokens. To use a property in `sprinkles({...})`, add it here first.
- `ui/`: reusable primitives, one folder per component (`ui/Button/` holds `Button.tsx`, `Button.css.ts` and an `index.ts` that is the folder's entry). `ui/index.ts` re-exports every folder, so code outside `ui/` imports from `@/ui` (`import { Button, Icons } from "@/ui"`). Inside `ui/`, components import each other by folder (`@/ui/Button`), never through `@/ui`, so the kit cannot import itself. `MarkdownPeek` is left out of the barrel because pages load it lazily from `@/ui/MarkdownPeek`; a new lazily loaded component stays out too. Recipes (`Button`, `Card`) compose sprinkles in `base` and `variants`. Interactive primitives wrap React Aria Components (import from `react-aria-components/<Name>`) for behavior and accessibility; style their states with the `data-hovered`, `data-pressed`, `data-focus-visible` and `data-disabled` attributes, not `:hover` or `:disabled`, and pass the recipe class through `className`. React Aria props replace the native ones (`onPress`, `isDisabled`).
- `layouts/`: app-specific layout routes (`AppShell`) with their `.css.ts`.

**Build constraint:** a `.css.ts` file imported at run time by a `.tsx` file cannot export functions. The build fails with "Invalid exports" or "Invalid function serialization params". Export plain objects, class strings, recipes or sprinkles results. Helper functions are fine when only other `.css.ts` files import them.

**Theme switching.** `atoms/theme.ts` is a Jotai `atomWithStorage` over plain-string `localStorage` (`"light"` or `"dark"`, falling back to the OS preference) and keeps `<html data-theme>` in sync. `public/theme-init.js`, loaded as a blocking script in `root.tsx`, sets the same attribute before first paint to avoid a flash of the wrong theme. Removing it causes that flash. It duplicates the atom's storage parsing, so changing the stored values means updating both.

**Stored settings.** The theme is the only setting in `localStorage`, since `theme-init.js` must read it synchronously. Every other per-browser preference (sidebar width and visibility, open tabs, code view toggles, the wallpaper layout) is an `atomWithSetting` from `atoms/settings.ts`, kept in the IndexedDB database `andrewix-settings` (store `settings`; favorites live apart in `andrewix`/`favorites`). The root route's `clientLoader` awaits `preloadSettings()`, which reads the whole store into memory before the first render, so atoms read their value synchronously and never flash the default; writes update memory at once, go to IndexedDB in the background and reach other tabs over a `BroadcastChannel`. Give each setting a type guard: a stored value that fails it reads as the default.

**Fonts and icons.** Fonts are Fontsource variable Roboto and Roboto Mono, injected by `unplugin-fonts` (`import "unfonts.css"` in `root.tsx`). Icons are imported as `~icons/mdi/<name>` through `unplugin-icons`.

**Side effects and the barrel.** `package.json` `sideEffects` lists the only files that run code on import (`*.css`, `*.css.ts`, `src/atoms/theme.ts`, `src/root.tsx`). That lets the build drop the `ui/` components a route does not use; without it every route loads the whole kit. A new file that does work at module level (a store subscription, a global listener, a bare `import "x"` target) must be added to that list, or the build silently drops it.

## Conventions

- Use tokens for every size, color and duration; no magic numbers and no `null` placeholder contracts.
- Do not use `dangerouslySetInnerHTML`.
- Do not silence lint rules (`biome-ignore`); fix the cause or restructure the code so the rule does not fire.
- Every exported style class (`style`, recipe or sprinkles result in a `.css.ts` file) gets a JSDoc comment. It describes only what the class is for, never its styling (colors, sizes, variants), since those change.
- Import across folders with the `@/` alias for `src/` (`@/styles/tokens.css`, `@/ui`), set in `tsconfig.json` `paths` and enabled in Vite with `resolve.tsconfigPaths`. Use `./` only for files in the same folder.
- Join class names with `clsx` (`clsx(s.base, isOpen && s.open, className)`), not `[...].filter(Boolean).join(" ")`.
- Biome is the formatter and linter: double quotes, 2-space indent, organized imports.
- Ask before structural decisions such as new folders or how to split a module.

### Sprinkles or `inComponents`

- If the property and value are in the sprinkles allowlist (`styles/sprinkles.css.ts`), use `sprinkles`. Otherwise use `inComponents`. A type error on a `sprinkles` call means the property is not in the allowlist.
- Never set the same property through both on one element: sprinkles are the `utilities` layer and always win.
- `:hover`, `:disabled` and other selectors or media queries always go in `inComponents`.
- Add a property to the allowlist only when it has a small set of token or keyword values and is repeated across about three components.
- `inBase` is for element selectors in `global.css.ts` only.

### Static vs dynamic styles

- Value known at build time → class (recipe, sprinkles or `inComponents`). Almost everything.
- Small closed set of values → one class per value, like `GridItem`'s span map.
- Value computed at runtime → `createVar()` in the `.css.ts`, assigned with `assignInlineVars` in the component. The only escape hatch.

Inline `style` may only assign CSS variables through `assignInlineVars`, never style properties. That keeps static rules winning predictably and every runtime-dynamic element findable by grepping `assignInlineVars`.
