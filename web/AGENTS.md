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
bun check          # Bun's built-in type checker
bun run lint       # biome lint --write --unsafe . (rewrites files)
bun run format     # biome format --write .
bunx biome check <file>   # check one file without the --unsafe rewrites
```

There is no test suite. Validate a change with `bun check`, `bunx biome check .` and `bun run build`.

## Architecture

**Routing.** React Router v8 framework mode as an SPA (`ssr: false`, `appDirectory: "src"`). Routes are declared in `src/routes.ts`; `layouts/AppShell.tsx` is the layout route and `root.tsx` holds the document shell. Route files are flat until a route needs a second file (`.css.ts`, hook, child component); then it gets a folder: `routes/<Name>/<Name>.tsx`, with no barrel because `routes.ts` imports the file by path. Route-local components stay in the route folder; only reusable primitives go in `ui/`.

**Styling is vanilla-extract, split across a few files that only make sense together:**

- `styles/tokens.css.ts`: the single source of design tokens. `vars` merges `themeVars` (values that differ in light and dark: `color`, `elevation`) with the shared tokens (`space`, `shape`, `type`, `motion`, ...). Shared tokens never go inside `light`/`dark`. `light`'s shape is the contract `dark` must satisfy. Colors come from `@catppuccin/palette`, mapped to Material 3 roles. `breakpoints` are plain strings because media queries cannot read CSS variables. `text` is a plain object of typography properties to spread into styles.
- `styles/global.css.ts`: applies the themes (`createGlobalTheme` on `:root[data-theme=...]` and nested `[data-theme=...]`, so a subtree can force a theme), the per-breakpoint layout variables, and element defaults.
- `styles/layers.css.ts`: cascade order `base` < `components` < `utilities`, plus the `inBase` and `inComponents` wrappers. It also holds `stateLayer`, the hover, focus and pressed feedback with focus ring that interactive components compose. Sprinkles are the `utilities` layer, so they beat component rules. Unlayered CSS beats every layer; `routes/*.css.ts` are intentionally unlayered.
- `styles/sprinkles.css.ts`: the utility allowlist. Only the listed properties and values exist, and values come from tokens. To use a property in `sprinkles({...})`, add it here first.
- `ui/`: reusable primitives, one folder per component (`ui/Button/` holds `Button.tsx`, `Button.css.ts` and an `index.ts` that is the public entry, imported as `../ui/Button`). Recipes (`Button`, `Card`) compose sprinkles in `base` and `variants`. Interactive primitives wrap React Aria Components (import from `react-aria-components/<Name>`) for behavior and accessibility; style their states with the `data-hovered`, `data-pressed`, `data-focus-visible` and `data-disabled` attributes, not `:hover` or `:disabled`, and pass the recipe class through `className`. React Aria props replace the native ones (`onPress`, `isDisabled`).
- `layouts/`: app-specific layout routes (`AppShell`) with their `.css.ts`.

**Build constraint:** a `.css.ts` file imported at run time by a `.tsx` file cannot export functions. The build fails with "Invalid exports" or "Invalid function serialization params". Export plain objects, class strings, recipes or sprinkles results. Helper functions are fine when only other `.css.ts` files import them.

**Theme switching.** `atoms/theme.ts` is a Jotai `atomWithStorage` over plain-string `localStorage` (`"light"` or `"dark"`, falling back to the OS preference) and keeps `<html data-theme>` in sync. `public/theme-init.js`, loaded as a blocking script in `root.tsx`, sets the same attribute before first paint to avoid a flash of the wrong theme. Removing it causes that flash. It duplicates the atom's storage parsing, so changing the stored values means updating both.

**Fonts and icons.** Fonts are Fontsource variable Roboto and Roboto Mono, injected by `unplugin-fonts` (`import "unfonts.css"` in `root.tsx`). Icons are imported as `~icons/mdi/<name>` through `unplugin-icons`.

## Conventions

- Use tokens for every size, color and duration; no magic numbers and no `null` placeholder contracts.
- Do not use `dangerouslySetInnerHTML`.
- Every exported style class (`style`, recipe or sprinkles result in a `.css.ts` file) gets a JSDoc comment. It describes only what the class is for, never its styling (colors, sizes, variants), since those change.
- Import across folders with the `@/` alias for `src/` (`@/styles/tokens.css`, `@/ui/Button`), set in `tsconfig.json` `paths` and enabled in Vite with `resolve.tsconfigPaths`. Use `./` only for files in the same folder.
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
