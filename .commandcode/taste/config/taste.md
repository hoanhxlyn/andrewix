# Config / Architecture

- Avoids introducing shared helpers/generic abstractions; prefers config inlined directly in the single module file that
  uses it, even when the logic is used only there ("don't split out as a helper"). Scope: Nix _declarative options_ stay
  inlined; the exception is _imperative shell code_, which goes to a `config/<tool>/` script (see the fish-extraction
  rule below). Confidence: 0.85
- Prefers referencing executables via Nix (`${pkgs.pkexec}/bin/...`) over hardcoded absolute system paths like
  `/run/wrappers/bin/...`. Confidence: 0.8
- Keeps a single source of truth and symlinks it elsewhere instead of duplicating content (e.g. an AGENTS file symlinked
  back to the Claude config). Confidence: 0.7
- Takes explicit control over tool/plugin behavior rather than letting it auto-generate config (e.g. don't let nvf
  auto-bind keys; strictly mirror a reference tool's behavior). Confidence: 0.7
- Manages coding-agent tooling declaratively via the Nix agents module: wants new tools (e.g. Command Code) wired into
  `modules/core/system/agents.nix` to match the existing agents, with MCP servers defined once in shared
  `programs.mcp.servers` and transformed into each tool's config format rather than duplicated. Confidence: 0.7
- In Nix modules, if a module takes no top-level arguments, write a bare attrset — omit the `_: ` prefix entirely (per
  AGENTS.md "No dead top-level args"). Confidence: 0.95
- Prefers user-level/global configuration over project-specific config when setting up personal tooling defaults.
  Confidence: 0.7
- Treats binary-cache (Cachix) coverage as a first-class design concern: audits which packages are actually compiled
  locally vs. fetched prebuilt, and expects `override`/`overrideAttrs`/patch-application to be flagged as cache-breaking
  (output path changes → no substituter hit) even when a Cachix for that input is configured. Prefers consuming prebuilt
  flake-input packages over hand-writing build recipes — config has zero `mkDerivation`s. Confidence: 0.6
- Repo layout (`/home/andrew/andrewix`): NixOS + Home Manager flake on the vic/den dendritic framework — modules under
  `modules/core/**`, `modules/devices/**`, `modules/_lib/**`, entry points under `hosts/**`; imperative per-tool shell
  snippets live under `config/<tool>/` (e.g. `config/command-code/install.fish`); `flake.nix` is auto-generated, so read
  only its input list and don't analyze it as authored code. Confidence: 0.6
- Migrating off a pre-NixOS Neovim config built on mason.nix + nvim-lspconfig, and uses that imperative setup as the
  correctness baseline for the declarative nvf one: when nvf behaves differently (e.g. only `typescript-go` attaches, no
  Biome LSP), reports the old pairing as the reference and asks if it was "the right way" — expects the agent to
  reconcile the two and say whether parity is warranted, not just why nvf differs. Confidence: 0.6
- Rejects all-or-nothing tooling choices: wants one global declaration that self-adapts per project ("i want a flexible
  way so i can work with both with or w/o biome in a project") — i.e. a server/tool gated on project marker files
  (`root_markers = ["biome.json" "biome.jsonc"]`, deliberately omitting `.git`) so it attaches only where used, instead
  of per-project config edits or manual switching. Note this refines (not reverses) the global-config preference: global
  by default, but conditioned on the project. Confidence: 0.75
- When choosing between implementation shapes, picks the one that leans on the tool's own native detection mechanism
  over custom imperative glue (rejected a `BufReadPost` autocmd toggling `vim.b.disableFormatSave` per buffer in favour
  of LSP root_markers + leaving the existing formatter chain untouched) — minimises churn in what actually
  formats/writes their code. Present such options as a small labelled set with the low-magic one marked recommended.
  Confidence: 0.7
- Deletes their own config the moment it turns out to be inert rather than keeping a hand-rolled approximation of what
  upstream already does — e.g. dropped a manual nvf `biome` `filetypes`/`root_markers` block in favour of
  nvim-lspconfig's bundled `root_dir` guard, leaving a presence-only `biome = {};` entry, and had dead LSP stubs renamed
  to the real server names so their settings actually apply. Expects a comment explaining _why_ a declaration that looks
  empty/dead is in fact load-bearing. Confidence: 0.65
- Organizes third-party Nix module config as a thin wiring module plus a per-tool subdirectory of split option files
  (e.g. `modules/core/editor/nvf.nix` only assigns
  `languages = import "${self}/modules/core/editor/_nvf/languages.nix"`, with `lsp.nix` etc. alongside); new settings go
  in the matching `_nvf/` file, not in the parent module. Confidence: 0.6
- Keeps imperative bootstrap/install logic out of Nix string literals (`home.activation.* = ''...bash...''`): extract it
  into a `config/<tool>/*.fish` script, then have the module just invoke it —
  `activation.<name> = "${lib.getExe pkgs.fish} ${self}/config/<tool>/<file>.fish";` — and widen the module's top-level
  args (`{ inputs, self, ... }`) only as needed for that reference. Wants the two moves done in one pass, as a paired
  change. Confidence: 0.8
- Shell of choice is fish: imperative bootstrap/install logic belongs in `.fish` files using fish idioms (`type -q`,
  `test -x`, `and` chains) rather than bash/zsh snippets, and such scripts must be idempotent — check the binary is
  absent (command lookup plus an explicit path fallback) before running the installer, never install unconditionally at
  load. Confidence: 0.75
- Follow-up setup steps (e.g. "add a post install of @config/<tool>/install.fish which run `cmdc skills add <repo>`")
  are layered _into the existing bootstrap script_ as an extra guarded section rather than added as a second
  `home.activation` entry or run manually afterwards — so a single activation hook stays the only Nix-visible surface
  and each step carries its own skip-if-present check (test the installed artifact path, e.g.
  `~/.commandcode/skills/<name>`) to keep the whole script idempotent. Confidence: 0.7
- Prefers the native Home Manager `programs.<app>` module (`enable` / `package` / `settings = { ... }` attrset) over a
  hand-rolled `xdg.configFile."app/config.toml".text` block whenever upstream HM ships one — a bare "Why are we using
  xdg to create herdr setting?" is a correction, not a request to justify the choice: search HM's
  `modules/programs/<app>.nix` first, admit the miss in one line, and switch (the native module also brings things the
  manual file can't, e.g. a `server reload-config` activation hook). Consequence: before writing any app's config by
  hand in this repo, check that a `programs.*` option doesn't already exist. Confidence: 0.8
- Standardizes on `alt+q` as the one terminal-level leader/prefix key: expects any new terminal tool that has its own
  prefix to be rebound from the upstream default (e.g. Herdr/tmux-style `ctrl+b` → `prefix = "alt+q"`) to match the
  `alt+q>…` prefix already used in their ghostty/kitty configs. Consequence: when adding such a tool, state the prefix
  explicitly in the declarative config and note which currently-active terminal (they run `rio`, which defines no
  `[bindings]`) leaves Alt+Q free — a future switch to ghostty/kitty would swallow it. Confidence: 0.7
