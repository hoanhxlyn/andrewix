# Tech stack

- NixOS + Home Manager via flake-parts; vic/den dendritic framework; vic/import-tree module auto-discovery; nixos-26.05 pins in flake.lock.
- Formatter: alejandra (2-space, <=100 cols) plus nix run .#attr-style (dotted-path rewrite, Rust sources in scripts/attr-style).
- Lint: statix, deadnix --no-underscore, custom comment-marker grep — all behind just lint.
- Secrets: sops-nix, shared age key at ~/.config/sops-nix/keys.txt per host.
- Shell: fish + direnv; Justfile is the single task entry point, non-trivial recipes call fish scripts in scripts/.
- Editor: nvf (neovim), config in modules/core/editor/_nvf.
- Windows interop only on WSL hosts (PATH interop disabled, 9p/DrvFs slow): invoke .exe by absolute path; wsl-open wrapper absorbs explorer.exe's non-zero exit.
- Agent tooling: uv-managed `serena-agent` and `specify-cli` (NOT nix-managed; upgrade with uv tool upgrade <tool>), OpenCode config in ~/.config/opencode, MCP servers wired in modules/core/agents/default.nix.
- uv gotcha: `uv tool install` picks the newest managed interpreter and IGNORES the package's own requires-python, so PyO3-based deps (pydantic-core, tiktoken) fail on 3.15 with "pyo3 caps at 3.14", and bare C deps fail for lack of `cc`. Always pass `--python '>=3.11,<3.15'`; a compiler toolchain does not fix it.
- web/: React Router v8 SPA on Bun + Vite + vanilla-extract, Biome, Playwright, Cloudflare Pages deploy. Details: `mem:web/core`.
