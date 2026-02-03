# AGENTS.md - NixOS Dotfiles Configuration (Andrewix)

This repository contains Andrew's NixOS and Home Manager configuration. It follows a modular architecture with automatic directory scanning.

## Build & Maintenance Commands

### System Management (Recommended)
```bash
# Apply changes and switch to new configuration
nh os switch ~/dotconfigs

# Update all flake inputs
nix flake update --flake ~/dotconfigs

# Check flake for evaluation errors
nix flake check

# Cleanup nix garbage and old generations
nh clean all

# Optimize nix store (deduplicate files)
nix store optimise
```

### Search & Shell
```bash
# Search for packages
nh search <package-name>

# Enter the project development shell
nix develop
```

## Architecture & Conventions

### Module Structure
- **NixOS (System):** `modules/system/features/`
- **Home Manager (User):** `modules/user/features/`
- **Hosts:** `modules/hosts/<hostname>/`
- **Flake Logic:** `modules/flake/`

We use `vic/import-tree` to automatically import all `.nix` files within `features/` directories. Simply adding a new file there integrates it into the build.

### Code Style Guidelines

#### Nix Formatting
- **Formatter:** Use `nixfmt` for all `.nix` files.
- **Indentation:** 2 spaces.
- **Imports:** Use relative paths (e.g., `./module.nix`) within modules.
- **Patterns:**
  - Standard input: `{ config, pkgs, inputs, ... }: { ... }`
  - Use `inherit` for repetitive attribute passing.
  - Organize settings by subsystem (e.g., `programs`, `services`).

#### Naming Conventions
- **Files:** `kebab-case.nix` (e.g., `keepassxc.nix`, `git-config.nix`).
- **Variables:** `camelCase` (e.g., `hostName`, `stateVersion`).
- **Booleans:** Prefix with `enable` or `disable` (e.g., `enable = true`).

#### Neovim (nvf)
- Configured via `programs.nvf.settings`.
- Follow the nested structure: `vim.*`, `vim.languages.*`, `vim.mini.*`.
- Keymaps: Use the `vim.keymaps` array with `mode`, `action`, and `desc`.

## Error Handling & Safety
- **State Version:** Fixed at `25.11`. **Do not change** unless performing a manual migration.
- **Safety Loop:** Always run `nix flake check` before committing significant structural changes.
- **Conditional Config:** Use `lib.mkIf` or `lib.mkDefault` when defining options that might be overridden or depend on other toggles.

## Repository Layout
```text
~/dotconfigs/
├── flake.nix              # Entry point (flake-parts)
├── modules/
│   ├── system/            # NixOS system-level config
│   │   ├── features/      # Auto-imported NixOS modules
│   │   └── configuration.nix
│   ├── user/              # Home Manager user-level config
│   │   ├── features/      # Auto-imported user modules
│   │   ├── bundle.nix
│   │   └── home.nix
│   ├── hosts/             # Hardware/Host specific configs
│   └── flake/             # mkSystem and host definitions
└── andrew.omp.json        # Theme for Oh My Posh
```

## Important Variables
- **Hostname:** `andrew-pc` or `andrew-laptop` (defined in `modules/flake/hosts.nix`)
- **Username:** `andrew`
- **LSP:** `nixd` for Nix, `lua-ls` for Lua.
