# AGENTS.md - Guidelines for Coding Agents

## Build/Lint/Test Commands

### Apply Configuration
```bash
nh os switch .              # Apply latest config (requires sudo)
nh os test .                # Validate config before commit (requires sudo)
nh os build .               # Build without switching
```

### Update & Maintenance
```bash
nix flake update --flake .  # Update all flake inputs
nix flake check             # Check for evaluation errors
nh search <query>           # Search for packages
```

### Formatting & Linting
```bash
alejandra .                 # Format all Nix files
statix check                # Lint for Nix best practices
deadnix --no-underscore --fail  # Find dead code
pre-commit run --all-files  # Run all pre-commit hooks
```

### Build Single Host
```bash
nh os build . --hostname andrew-pc
nh os build . --hostname andrew-laptop
```

**Note:** No unit tests - validation via `nh os test .` and `nix flake check`.

## Project Architecture

NixOS + Home Manager config using **flake-parts** with **dendritic (aspect-first) architecture** and automatic module discovery via `vic/import-tree`.

### Directory Structure
```
├── flake.nix           # Auto-generated (DO NOT EDIT)
├── modules/
│   ├── dendritic.nix  # Dendritic module loader
│   ├── namespace.nix   # Namespace definitions (core, andrew, my)
│   ├── defaults.nix   # Default includes for all hosts
│   ├── home-manager.nix
│   ├── treefmt.nix
│   ├── core/          # System-level aspects (NixOS modules)
│   ├── andrew/        # User-level aspects (Home Manager)
│   └── my/            # Host/user definitions
├── hosts/              # Hardware-specific configs
│   ├── andrew-pc/
│   └── andrew-laptop/
└── config/             # Config files (neovim, etc.)
```

### Key Variables
- Username: `andrew`
- System: `x86_64-linux`
- State Version: `25.11` (DO NOT MODIFY)

## Code Style Guidelines

### Formatting
- **Formatter:** `alejandra` (enforced by treefmt)
- **Indentation:** 2 spaces (no tabs)
- **Line Length:** Prefer under 80 chars, hard limit at 100

### Naming Conventions
- **Files/Directories:** `kebab-case.nix` / `kebab-case`
- **Variables/Options:** `camelCase`
- **Booleans:** Prefix with `enable`/`disable`

### Module Structure Pattern
```nix
{__findFile, ...}: {
  core.featureName = {
    includes = [ (<den/unfree> ["package"]) ];
    nixos = {config, pkgs, ...}: { /* NixOS config */ };
    homeManager = {pkgs, ...}: { /* Home Manager config */ };
  };
}
```

### Standard Function Arguments
- `{__findFile, ...}:` - Modules using den includes
- `{config, pkgs, ...}:` - NixOS/homeManager configs
- `{lib, ...}:` - Only lib functions needed
- `{inputs, self, ...}:` - Referencing flake inputs

### Imports & Includes
- Use `includes = [ ... ]` for den aspect dependencies
- Use angle bracket syntax: `<den/define-user>`, `<my/devices/home-pc>`
- Use `imports = [ ... ]` for Home Manager module imports

### Common Functions
- `lib.mkEnableOption` - Boolean enable options
- `lib.mkOption` - Custom options
- `lib.mkIf` - Conditional configuration
- `lib.mkMerge` - Merge multiple configs
- `lib.mkDefault` - Set default values (overrideable)

### Flake Inputs Pattern
```nix
{inputs, ...}: {
  flake-file.inputs.newInput = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

## Error Handling
- Use `lib.mkDefault` for overridable values
- Run `nix flake check` before committing
- Always run `nh os test .` before `nh os switch .`

## Important Rules

1. **NEVER** edit `flake.nix` directly - auto-generated via `nix run .#write-flake`
2. **NEVER** change state version (`25.11`)
3. **ALWAYS** run `nh os test .` before committing
4. **ALWAYS** format with `alejandra .` before committing
5. **ALWAYS** check lint with `statix check`
6. Use `with pkgs;` for package lists
7. Use `inherit` when appropriate
8. Place related packages in same `environment.systemPackages` list
9. Always use context7 and websearch to research and confirm your knowledge

## Pre-commit Hooks
- `alejandra` - Nix formatter
- `deadnix` - Dead code detection
- `statix` - Nix linter
- `nixf-diagnose` - Additional diagnostics

Excluded: `modules/*`, `LICENSE`, `flake.lock`, `.envrc`, `.direnv/*`
