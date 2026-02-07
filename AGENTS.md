# AGENTS.md - NixOS Dotfiles Configuration (Andrewix)

This repository contains Andrew's NixOS and Home Manager configuration using flake-parts with automatic module discovery. The architecture follows a dendritic (tree-like) structure with category-based organization.

## Build, Lint & Test Commands

### System Management
```bash
# Apply changes and switch to new configuration
nh os switch ~/dotconfigs

# Build configuration without switching (dry run)
nh os build ~/dotconfigs

# Update all flake inputs
nix flake update --flake ~/dotconfigs

# Check flake for evaluation errors
nix flake check

# Regenerate flake.nix from modules (uses vic/flake-file)
nix run .#write-flake

# Cleanup nix garbage and old generations
nh clean all

# Optimize nix store (deduplicate files)
nix store optimise
```

### Code Quality & Formatting
```bash
# Format all Nix files (uses alejandra)
alejandra .

# Lint for Nix best practices (statix)
statix check

# Find unused bindings (deadnix)
deadnix --fail

# Run all pre-commit hooks manually
pre-commit run --all-files

# Enter development shell with all tools
nix develop
```

### Package Management
```bash
# Search for packages
nh search <package-name>

# Enter the project development shell
nix develop

# Enter CI-specific shell
nix develop .#ci
```

## Architecture & Conventions

### Module Structure (Auto-Discovery)
- **NixOS System:** `modules/system/categories/` (auto-imported)
- **Home Manager User:** `modules/user/categories/` (auto-imported)
- **Hosts:** `modules/hosts/<hostname>/` (host-specific configs)
- **Flake Logic:** `modules/hosts.nix` (system definitions)

We use `vic/import-tree` for automatic module discovery. Any `.nix` file in `categories/` directories is automatically imported and integrated into the build.

### Module Categories
- **System Categories:**
  - `core/`: Core system programs, fonts, i18n, services
  - `shell/`: Shell environments and CLI tools
- **User Categories:**
  - `development/`: Git, Neovim, development tools
  - `desktop/`: Browsers, terminals, file managers
  - `utilities/`: KeePassXC, agents, shell, misc tools

### Code Style Guidelines

#### Nix Formatting
- **Formatter:** `alejandra` (enforced by pre-commit)
- **Indentation:** 2 spaces (no tabs)
- **Line Length:** Prefer under 80 characters
- **File Encoding:** UTF-8

#### Module Patterns
- **Standard Input:** `{ config, pkgs, inputs, ... }: { ... }`
- **Relative Imports:** Use `./module.nix` within categories
- **Parameter Passing:** Use `inherit` for repetitive attributes
- **Organization:** Group by subsystem (`programs`, `services`, `environment`)

#### Naming Conventions
- **Files:** `kebab-case.nix` (e.g., `keepassxc.nix`, `git-config.nix`)
- **Variables:** `camelCase` (e.g., `hostName`, `stateVersion`, `fontFamily`)
- **Booleans:** Prefix with `enable` or `disable` (e.g., `enable = true`)
- **Categories:** Use descriptive directory names (`categories/development`, `categories/desktop`)

#### Attribute Organization
```nix
{
  # Core settings first
  programs.<program> = { ... };
  services.<service> = { ... };
  environment.systemPackages = with pkgs; [ ... ];
  
  # Then user-specific
  home.packages = with pkgs; [ ... ];
  xdg.configFile = { ... };
}
```

#### Function Parameters
- Accept common parameters: `{ config, pkgs, inputs, lib, ... }`
- Use `...` ellipsis for parameter extensibility
- Leverage specialArgs from `mkSystem` for shared values

### Error Handling & Safety
- **State Version:** Fixed at `25.11`. **Do not change** without manual migration
- **Safety Loop:** Always run `nix flake check` before structural changes
- **Conditional Config:** Use `lib.mkIf`, `lib.mkDefault`, `lib.mkMerge` for conditional logic
- **Overrides:** Use `lib.mkOverride` for forcing specific values

### Pre-commit Hooks
- **alejandra:** Code formatting
- **statix:** Linting for best practices
- **deadnix:** Detection of unused code

## Repository Layout
```text
~/dotconfigs/
├── flake.nix              # Auto-generated entry point (DO NOT EDIT)
├── outputs.nix            # Main flake configuration (flake-parts)
├── modules/
│   ├── hosts.nix          # System definitions and mkSystem helper
│   ├── system/            # NixOS system-level configs
│   │   └── categories/    # Auto-imported system modules
│   │       ├── core/      # Core programs, fonts, services
│   │       └── shell/     # Shell environments
│   └── user/              # Home Manager user-level configs
│       ├── home.nix        # Main user configuration
│       └── categories/    # Auto-imported user modules
│           ├── development/ # Dev tools, git, neovim
│           ├── desktop/   # GUI apps, browsers, terminals
│           └── utilities/  # CLI tools and utilities
├── hosts/                 # Hardware-specific configurations
│   ├── andrew-pc/         # Desktop configuration
│   └── andrew-laptop/     # Laptop configuration
└── andrew.omp.json        # Oh My Posh theme
```

## Important Variables
- **Hostnames:** `andrew-pc` or `andrew-laptop` (defined in `modules/hosts.nix`)
- **Username:** `andrew`
- **State Version:** `25.11` (do not modify)
- **Font Family:** `CaskaydiaCove Nerd Font`
- **System:** `x86_64-linux`

## Development Environment
- **LSP:** `nixd` for Nix, `lua-ls` for Lua
- **Dev Shell:** Includes `git`, `neovim`, `alejandra`, `statix`, `deadnix`
- **CI Shell:** Lightweight shell with just formatting/linting tools
