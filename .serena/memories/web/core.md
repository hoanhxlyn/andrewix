# web/ — React SPA (outside the Nix build)

React Router v8 framework mode SPA (ssr: false, appDirectory src), Bun runtime and package manager, Vite, vanilla-extract + React Aria, Jotai/IndexedDB settings, Biome, Playwright e2e, deployed to Cloudflare Pages (andrewix.pages.dev). web/AGENTS.md is the authoritative deep doc — read it before editing; below are the traps.

- Run commands from web/. Never npm, node, npx or tsc (typescript is not a dependency); use bunx for one-off CLIs.
- Commands: bun install; bun run dev|build|preview|deploy|walls|test|e2e; bun check (type check); bun run lint|format (biome --write, rewrites files); bunx biome check <file> to check without rewriting.
- Routing: src/routes.ts is the route table; src/routes/<Name>.tsx (folder only when it needs .css.ts or child routes). Page URL/action state lives in a hook in src/hooks/, page components in components/<Page>/, shared primitives in ui/ (import @/ui from outside, @/ui/<Folder> inside).
- Tests: unit tests only in src/__test__/ mirroring src/, imported via the @/ alias; bunfig.toml roots bun test at src/, Playwright owns e2e/. A unit-tested module must not touch import.meta.glob, virtual: modules or .css.ts files.
- Build constraints: a .css.ts imported at run time by a .tsx may export only plain objects/class strings/recipes/sprinkles results — functions break the build. package.json sideEffects must list every module-level side effect or the ui/ kit gets tree-shaken away.
- Styling: tokens only (styles/tokens.css.ts); sprinkles allowlist (styles/sprinkles.css.ts) wins over components; selectors and media queries go in inComponents; runtime-computed values use createVar + assignInlineVars, never inline style properties.
- Validation gate: bun check, bunx biome check ., bun run test, bun run build; add bun run e2e when the UI changes. `just lint` at the repo root also enforces the comment-marker rule on web/.
