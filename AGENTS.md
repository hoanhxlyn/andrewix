# AGENTS.md - Guidelines for Coding Agents

## Build/Lint/Test Commands

### Apply Configuration
```bash
nh os switch .                          # Apply latest config (requires sudo)
nh os test .                            # Validate config before commit (requires sudo)
nh os build .                           # Build without switching
```

### Update & Maintenance
```bash
nix flake update --flake .              # Update all flake inputs
nix flake check                         # Check for evaluation errors
nh search <query>                       # Search for packages
```

### Formatting & Linting
```bash
alejandra .                             # Format all Nix files
statix check                            # Lint for Nix best practices
deadnix --no-underscore --fail          # Find dead code
pre-commit run --all-files              # Run all pre-commit hooks
```

### Build Single Host
```bash
nh os build .                    # Build default host
nh os build . --hostname andrew-pc
nh os build . --hostname andrew-laptop
```

### Regenerate flake.nix
```bash
nix run .#write-flake                   # Regenerate auto-generated flake.nix
```

**Note:** There are no unit tests in this configuration repository. Validation is done via `nh os test .` and `nix flake check`.

## Project Architecture

This is a NixOS and Home Manager configuration using **flake-parts** with **dendritic (aspect-first) architecture** and automatic module discovery via `vic/import-tree`.

### Directory Structure
```
├── flake.nix              # Auto-generated entry point (DO NOT EDIT)
├── modules/
│   ├── dendritic.nix      # Dendritic module loader
│   ├── namespace.nix      # Namespace definitions (core, andrew, my)
│   ├── defaults.nix       # Default includes for all hosts
│   ├── home-manager.nix   # Home Manager integration
│   ├── treefmt.nix        # Formatting configuration
│   ├── core/              # System-level aspects (NixOS modules)
│   ├── andrew/            # User-level aspects (Home Manager modules)
│   ├── my/                # Host/user definitions and custom settings
│   └── hosts.nix          # Host discovery
├── hosts/                 # Hardware-specific configurations
│   ├── andrew-pc/
│   └── andrew-laptop/
└── config/                # Configuration files (neovim, etc.)
```

### Hosts
- `andrew-pc`: Desktop configuration
- `andrew-laptop`: Laptop configuration

### Key Variables
- Username: `andrew`
- System: `x86_64-linux`
- State Version: `25.11` (DO NOT MODIFY)

## Code Style Guidelines

### Formatting
- **Formatter:** `alejandra` (enforced by treefmt)
- **Indentation:** 2 spaces (no tabs)
- **Line Length:** Prefer under 80 characters, hard limit at 100
- **Encoding:** UTF-8

### Naming Conventions
- **Files:** `kebab-case.nix`
- **Directories:** `kebab-case`
- **Variables/Options:** `camelCase`
- **Booleans:** Prefix with `enable` or `disable` (e.g., `enable = true`)

### Module Structure Pattern

#### Standard Aspect Module
```nix
{__findFile, ...}: {
  core.featureName = {
    includes = [  # Optional: include other aspects
      (<den/unfree> ["package-name"])
    ];
    nixos = {config, pkgs, ...}: {
      # NixOS system configuration
    };
    homeManager = {pkgs, ...}: {
      # Home Manager user configuration
    };
  };
}
```

#### Provides Pattern (for modular features)
```nix
{lib, self, ...}: {
  andrew.category.provides.featureName = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs [ package1 package2 ];
    };
    homeManager = {pkgs, ...}: {
      programs.tool = { enable = true; };
    };
  };
}
```

### Standard Function Arguments
```nix
{config, pkgs, inputs, lib, self, __findFile, ...}: { ... }
```

Common argument patterns:
- `{__findFile, ...}:` - For modules using den includes
- `{config, pkgs, ...}:` - For NixOS/homeManager configs
- `{lib, ...}:` - When only lib functions needed
- `{inputs, self, ...}:` - When referencing flake inputs

### Imports & Includes
- Use `includes = [ ... ]` for den aspect dependencies
- Use angle bracket syntax for den paths: `<den/define-user>`, `<my/devices/home-pc>`
- Use `imports = [ ... ]` for Home Manager module imports

### Common Functions
- `lib.mkEnableOption` - Create boolean enable options
- `lib.mkOption` - Create custom options
- `lib.mkIf` - Conditional configuration
- `lib.mkMerge` - Merge multiple configurations
- `lib.mkDefault` - Set default values

### Flake Inputs Pattern
When adding new flake inputs, add to the module that uses them:
```nix
{
  inputs,
  ...
}: {
  flake-file.inputs.newInput = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";  # If it uses nixpkgs
  };
}
```

## Error Handling

- Use `lib.mkDefault` for values that can be overridden
- Check configurations with `nix flake check` before committing
- Always run `nh os test .` before `nh os switch .` to catch errors

## Important Rules

1. **NEVER** edit `flake.nix` directly - it is auto-generated
2. **NEVER** change the state version (`25.11`)
3. **ALWAYS** run `nh os test .` before committing changes
4. **ALWAYS** format code with `alejandra .` before committing
5. **ALWAYS** check for lint errors with `statix check`
6. Use `with pkgs;` for package lists to reduce verbosity
7. Use `inherit` for variable assignments when appropriate
8. Place related packages in the same `environment.systemPackages` list

## Pre-commit Hooks

The project uses treefmt-nix with these formatters/linters:
- `alejandra` - Nix formatter
- `deadnix` - Dead code detection
- `statix` - Nix linter
- `nixf-diagnose` - Additional Nix diagnostics

Excluded paths: `modules/*`, `LICENSE`, `flake.lock`, `.envrc`, `.direnv/*`
