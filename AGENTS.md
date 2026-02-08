# AGENTS.md - NixOS Dotfiles Configuration (Andrewix)

Dendritic NixOS configuration using flake-parts with aspect-first architecture and automatic module discovery via `vic/import-tree`.

## Build, Lint & Test Commands

### Quick Commands
```bash
nix develop                          # Enter dev shell with all tools
nix flake check                      # Validate flake (RUN BEFORE COMMITS)
alejandra .                          # Format all Nix files
statix check && deadnix --fail       # Lint & find unused code
pre-commit run --all-files           # Run all pre-commit hooks
```

### Testing & Building
```bash
# Test specific host (validate without switching)
nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel
nix build .#nixosConfigurations.andrew-laptop.config.system.build.toplevel

# Test single aspect by building a host that uses it
nix build .#nixosConfigurations.andrew-pc  # Tests GPU (nvidia) + gaming (xone)

# Dry-run without applying
nh os build ~/dotconfigs
```

### System Changes
```bash
nh os switch ~/dotconfigs           # Apply config (actual switch)
nix flake update --flake ~/dotconfigs  # Update all inputs
nix run .#write-flake               # Regenerate flake.nix (auto-generated)
nh clean all                         # Cleanup old generations
nix store optimise                  # Deduplicate store (slow, optional)
```

### Debugging
```bash
nix-instantiate --eval /path/to/file.nix  # Check file syntax
nix eval .#nixosConfigurations.andrew-pc  # Evaluate full config
nix flake metadata                   # Show flake inputs/outputs
```

## Architecture

### Module Structure
-   **System aspects:** `modules/system/aspects/{core,desktop,gpu,gaming,utilities}/` → auto-imported
-   **User aspects:** `modules/user/aspects/{development,desktop,utilities}/` → auto-imported via `vic/import-tree`
-   **Hosts:** `modules/hosts/{andrew-pc,andrew-laptop}/default.nix` → enable specific aspects
-   **Flake logic:** `modules/hosts.nix` (system definitions), `outputs.nix` (flake-parts config)

### Aspect Enable Pattern
System aspects use enable flags in `modules/system/aspects/default.nix`:
```nix
options.aspects = with lib; {
  desktop.enable = mkEnableOption "Desktop environment (GNOME)" // {default = true;};
  gpu.nvidia.enable = mkEnableOption "NVIDIA GPU support" // {default = false;};
  gaming.xone.enable = mkEnableOption "Xbox One controller driver" // {default = false;};
  utilities.enable = mkEnableOption "System utilities" // {default = true;};
};
```
Host configs set these flags; each aspect is always imported but gated with `lib.mkIf config.aspects.*.enable`.

## Code Style Guidelines

### Formatting & Organization
-   **Formatter:** `alejandra` (enforced by pre-commit)
-   **Indentation:** 2 spaces (no tabs)
-   **Line Length:** Prefer under 80 characters
-   **Encoding:** UTF-8

### Naming Conventions
-   **Files:** `kebab-case.nix` (e.g., `keepassxc.nix`, `gpu-nvidia.nix`)
-   **Variables:** `camelCase` (e.g., `hostName`, `stateVersion`)
-   **Booleans:** Prefix with `enable` or `disable` (e.g., `enable = true`)

### Module Patterns
-   **Standard Input:** `{ config, pkgs, inputs, ... }: { ... }`
-   **Imports:** Relative paths within aspects (e.g., `./gpu-nvidia.nix`)
-   **Parameter Passing:** Use `inherit` for repetitive attributes
-   **Organization:** Group by subsystem (`programs`, `services`, `environment`)

### Types & Type Safety
-   Use `lib.mkEnableOption` for boolean options
-   Use `lib.mkOption` for typed attributes with `lib.types`
-   Always validate inputs in option definitions

### Error Handling & Safety
-   **State Version:** Fixed at `25.11` (do not change without manual migration)
-   **Pre-Commit Check:** Always run `nix flake check` before commits
-   **Conditional Config:** Use `lib.mkIf`, `lib.mkDefault`, `lib.mkMerge`
-   **Overrides:** Use `lib.mkOverride` for forcing specific values

## Important Variables

-   **Hostnames:** `andrew-pc` or `andrew-laptop`
-   **Username:** `andrew`
-   **State Version:** `25.11` (do not modify)
-   **Font Family:** `CaskaydiaCove Nerd Font`
-   **System:** `x86_64-linux`
