# AGENTS.md - NixOS Dotfiles Configuration (Andrewix)

This repository contains Andrew's NixOS and Home Manager configuration using flake-parts with automatic module discovery. The architecture follows a dendritic (tree-like) structure with category-based organization.

## Build, Lint & Test Commands

### System Management

*   **Apply changes and switch to new configuration:**
    ```bash
    nh os switch ~/dotconfigs
    ```
*   **Build configuration without switching (dry run):**
    ```bash
    nh os build ~/dotconfigs
    ```
*   **Update all flake inputs:**
    ```bash
    nix flake update --flake ~/dotconfigs
    ```
*   **Check flake for evaluation errors (run before commits):**
    ```bash
    nix flake check
    ```
*   **Regenerate flake.nix from modules (uses vic/flake-file):**
    ```bash
    nix run .#write-flake
    ```
*   **Cleanup nix garbage and old generations:**
    ```bash
    nh clean all
    ```
*   **Optimize nix store (deduplicate files):**
    ```bash
    nix store optimise
    ```

### Testing

This project does not have a traditional test suite. Testing is performed by building and evaluating the NixOS configuration.

*   **Test specific host configuration:**
    ```bash
    nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel
    ```

### Code Quality & Formatting

*   **Format all Nix files (uses alejandra):**
    ```bash
    alejandra .
    ```
*   **Lint for Nix best practices (statix):**
    ```bash
    statix check
    ```
*   **Find unused bindings (deadnix):**
    ```bash
    deadnix --fail
    ```
*   **Run all pre-commit hooks manually:**
    ```bash
    pre-commit run --all-files
    ```
*   **Enter development shell with all tools:**
    ```bash
    nix develop
    ```
*   **Check specific file for syntax errors:**
    ```bash
    nix-instantiate --eval /path/to/file.nix
    ```

## Architecture & Conventions

### Module Structure (Auto-Discovery)

-   **NixOS System:** `modules/system/aspects/` (auto-imported)
-   **Home Manager User:** `modules/user/aspects/` (auto-imported)
-   **Hosts:** `modules/hosts/<hostname>/` (host-specific configs)
-   **Flake Logic:** `modules/hosts.nix` (system definitions)

We use `vic/import-tree` for automatic module discovery. Any `.nix` file in `aspects/` directories is automatically imported and integrated into the build.

### Module Categories

-   **System Categories:**
    -   `core/`: Core system programs, fonts, i18n, services
    -   `shell/`: Shell environments and CLI tools
-   **User Categories:**
    -   `development/`: Git, Neovim, development tools
    -   `desktop/`: Browsers, terminals, file managers
    -   `utilities/`: KeePassXC, agents, shell, misc tools

### Code Style Guidelines

#### Nix Formatting

-   **Formatter:** `alejandra` (enforced by pre-commit)
-   **Indentation:** 2 spaces (no tabs)
-   **Line Length:** Prefer under 80 characters
-   **File Encoding:** UTF-8

#### Naming Conventions

-   **Files:** `kebab-case.nix` (e.g., `keepassxc.nix`, `git-config.nix`)
-   **Variables:** `camelCase` (e.g., `hostName`, `stateVersion`, `fontFamily`)
-   **Booleans:** Prefix with `enable` or `disable` (e.g., `enable = true`)

#### Module Patterns

-   **Standard Input:** `{ config, pkgs, inputs, ... }: { ... }`
-   **Relative Imports:** Use `./module.nix` within aspects.
-   **Parameter Passing:** Use `inherit` for repetitive attributes.
-   **Organization:** Group by subsystem (`programs`, `services`, `environment`).

#### Types & Type Safety

-   Use `lib.mkEnableOption` for boolean options.
-   Use `lib.mkOption` for typed attributes.
-   Leverage `lib.types` for complex type definitions.
-   Always validate inputs in option definitions.

### Error Handling & Safety

-   **State Version:** Fixed at `25.11`. **Do not change** without manual migration.
-   **Safety Loop:** Always run `nix flake check` before structural changes.
-   **Conditional Config:** Use `lib.mkIf`, `lib.mkDefault`, `lib.mkMerge` for conditional logic.
-   **Overrides:** Use `lib.mkOverride` for forcing specific values.

### Pre-commit Hooks

-   **alejandra:** Code formatting
-   **statix:** Linting for best practices
-   **deadnix:** Detection of unused code

## Important Variables

-   **Hostnames:** `andrew-pc` or `andrew-laptop`
-   **Username:** `andrew`
-   **State Version:** `25.11` (do not modify)
-   **Font Family:** `CaskaydiaCove Nerd Font`
-   **System:** `x86_64-linux`
