# Tech stack

- NixOS (nixos-26.05 unstable-era pins in flake.lock) + Home Manager, flake-parts, vic/den dendritic framework, vic/import-tree module auto-discovery.
- Formatter: alejandra only (nixfmt disabled in tools); 2-space indent, <=100 chars. Attribute-style rewrite via nix run .#attr-style.
- Lint: statix, deadnix --no-underscore, custom comment-marker check (just lint).
- Secrets: sops-nix, shared age key at ~/.config/sops-nix/keys.txt per host.
- Shell: fish (+ direnv use flake). Justfile as task runner.
- MCP/AI tooling: OpenCode (v2 config in ~/.config/opencode), serena MCP via uv tool serena-agent (NOT nix-managed, update with uv tool upgrade serena-agent), uv-managed specify-cli.
- Editor: nvf (neovim), config in modules/core/editor/_nvf.
- Windows interop only on WSL hosts with PATH interop disabled (9p slow): invoke .exe by absolute path, wsl-open wrapper for explorer.
