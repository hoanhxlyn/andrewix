# AGENTS.md - NixOS Dotfiles Configuration (Andrewix)

Dendritic NixOS configuration using flake-parts with aspect-first architecture and automatic module discovery via `vic/import-tree`.

## Build, Lint & Test Commands

### Quick Commands
```bash
nix develop                          # Enter dev shell with all tools
nh os test .                         # Validate config (RUN BEFORE COMMITS - requires sudo)
alejandra .                          # Format all Nix files
statix check && deadnix --fail       # Lint & find unused code
pre-commit run --all-files           # Run all pre-commit hooks
```

### Searching for Packages
When looking for a package name in nixpkgs, ALWAYS use:
```bash
nh search <query>
```
Avoid using `nix-env -qa` or `nix search` as `nh search` provides a more readable and efficient interface for this project.

### Testing & Building (Single Aspect)
```bash
# Test specific host (validate without switching)
nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel
nix build .#nixosConfigurations.andrew-laptop.config.system.build.toplevel

# Evaluate and debug
nix eval .#nixosConfigurations.andrew-pc.config.aspects.gpu.nvidia.enable
nix-instantiate --eval /path/to/file.nix  # Check file syntax

# Dry-run build
nh os build .
```

### System Changes
```bash
nh os switch .           # Apply config (actual switch)
nix flake update --flake .  # Update all inputs
nix run .#write-flake               # Regenerate flake.nix (auto-generated)
nh clean all                         # Cleanup old generations
```

## Architecture

### Module Structure
- **System aspects:** `modules/system/aspects/{core,desktop,gpu,gaming,utilities}/` → auto-imported
- **User aspects:** `modules/user/aspects/{development,desktop,utilities}/` → auto-imported via `vic/import-tree`
- **Hosts:** `modules/hosts/{andrew-pc,andrew-laptop}/default.nix` → enable specific aspects
- **Flake logic:** `modules/hosts.nix` (system definitions), `outputs.nix` (flake-parts config)

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
- **Formatter:** `alejandra` (enforced by pre-commit) - MUST run before commits
- **Indentation:** 2 spaces (no tabs)
- **Line Length:** Prefer under 80 characters, hard limit at 100
- **Encoding:** UTF-8
- **Newline:** Trailing newlines required, no trailing whitespace

### Naming Conventions
- **Files:** `kebab-case.nix` (e.g., `keepassxc.nix`, `gpu-nvidia.nix`)
- **Directories:** `kebab-case` (e.g., `gpu-nvidia`, `package-manager`)
- **Variables/Options:** `camelCase` (e.g., `hostName`, `stateVersion`)
- **Booleans:** Prefix with `enable` or `disable` (e.g., `enable = true`)
- **Package names:** Use attribute name from nixpkgs (e.g., `pkgs.keepassxc`)

### Module Patterns
- **Standard Input:** `{ config, pkgs, inputs, lib, ... }: { ... }`
- **Imports:** Relative paths within aspects (e.g., `./gpu-nvidia.nix`)
- **Parameter Passing:** Use `inherit` for repetitive attributes
- **Organization:** Group by subsystem: `imports`, `options`, `config.services`, `config.programs`, `config.environment`

### Types & Type Safety
- Use `lib.mkEnableOption` for boolean options with `{default = true/false;}`
- Use `lib.mkOption` for typed attributes with `lib.types.*`
- Common types: `lib.types.bool`, `lib.types.str`, `lib.types.int`, `lib.types.listOf lib.types.str`
- Always validate inputs in option definitions with `lib.asserts`
- Use `lib.mkIf` for conditional configuration

### Error Handling & Safety
- **State Version:** Fixed at `25.11` (do not change without manual migration)
- **Validation:** ALWAYS run `nh os test .` before committing changes to verify the build.
- **Conditional Config:** Use `lib.mkIf`, `lib.mkDefault`, `lib.mkMerge`
- **Overrides:** Use `lib.mkOverride` for forcing specific values
- **Assertions:** Use `lib.asserts.assertTrue` for validation

### Nix Language Patterns
```nix
# Preferred: mkIf for conditionals
environment.systemPackages = lib.mkIf config.aspects.gaming.enable [
  pkgs.xone-driver
];

# Preferred: mkDefault for sensible defaults
services.foo.enable = lib.mkDefault true;

# Preferred: mkMerge for merging multiple sources
users.users = lib.mkMerge [
  (lib.mkIf cfg.createUser { "${username}" = { ... }; })
  (lib.mkIf cfg.extraGroups { "${username}" = { extraGroups = [...]; }; })
];
```

## Important Variables
- **Hostnames:** `andrew-pc`, `andrew-laptop`
- **Username:** `andrew`
- **State Version:** `25.11`
- **Font Family:** `CaskaydiaCove Nerd Font`

## Common Operations

### Adding a New Package
1. Search for the correct package name with `nh search <package>`
2. Add to appropriate aspect's `environment.systemPackages` or `home.sessionVariables`
3. Run `nh os test .` to validate the build
4. Use `alejandra .` to format

### Adding a New Host
1. Create directory `modules/hosts/<hostname>/`
2. Add `default.nix` with host configuration
3. Add to `modules/hosts.nix` with aspect selections
4. Test with `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
