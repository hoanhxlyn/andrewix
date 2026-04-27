# AGENTS.md - Guidelines for Coding Agents

## Build/Lint/Test Commands

### Apply Configuration
```bash
nix run .#andrew-laptop -- switch   # Apply config to andrew-laptop
nix run .#andrew-pc -- switch       # Apply config to andrew-pc
nix run .#andrew-laptop -- test      # Validate config before commit (requires sudo)
```

### Update & Maintenance
```bash
nix flake update --flake .          # Update all flake inputs
nix flake check                     # Check for evaluation errors
nps <query>                         # Search packages
```

### Formatting & Linting
```bash
alejandra .                         # Format all Nix files
statix check                        # Lint for Nix best practices
deadnix --no-underscore --fail      # Find dead code
pre-commit run --all-files         # Run all pre-commit hooks
```

### Build Single Host
```bash
nix run .#write-flake               # Regenerate flake.nix (DO NOT edit manually)
```

**Note:** No unit tests - validation via `nix run .#<host> -- test` and `nix flake check`.

## Project Architecture

NixOS + Home Manager config using **flake-parts** with a **dendritic (aspect-first)
architecture** and automatic module discovery via `vic/import-tree`.

### Directory Structure
```
├── flake.nix           # Auto-generated (DO NOT EDIT)
├── flake.lock          # Pinned dependency lockfile
├── modules/
│   ├── dendritic.nix   # Dendritic module loader (vic/den framework)
│   ├── namespace.nix   # Namespace definitions (core, andrew, my)
│   ├── defaults.nix    # Default includes for all hosts
│   ├── home-manager.nix
│   ├── treefmt.nix     # Formatting/linting pipeline
│   ├── core/           # System-level aspects (NixOS)
│   ├── andrew/         # User-level aspects (Home Manager)
│   └── my/             # Host/user identity definitions
├── hosts/              # Hardware-specific configs (filesystems, hardware)
│   ├── andrew-pc/
│   └── andrew-laptop/
└── config/             # Non-Nix application configs
    └── neovix/         # Neovim config (Lua)
```

### Namespace Conventions
- `core.<name>` — System-level aspect; configures NixOS
- `andrew.<category>` — User-level aspect; configures Home Manager
- `andrew.<category>.provides.<name>` — Parameterized/factory aspect
- `my.<name>` — Identity/host definitions (users, devices, state)

### Key Variables
- Username: `andrew`
- System: `x86_64-linux`
- State Version: `25.11` (DO NOT MODIFY)

---

## Nix Code Style

### Formatting
- **Formatter:** `alejandra` (enforced via treefmt + pre-commit)
- **Indentation:** 2 spaces (no tabs)
- **Line Length:** Prefer under 80 chars, hard limit at 100

### Naming Conventions
- **Files/Directories:** `kebab-case.nix` / `kebab-case`
- **Variables/Options:** `camelCase`
- **Booleans:** Prefix with `enable`/`disable`

### Module Structure Patterns

Simple aspect (no external deps):
```nix
{
  core.sound.nixos = {
    services.pipewire.enable = true;
  };
}
```

Aspect with den includes (angle-bracket imports):
```nix
{__findFile, ...}: {
  core.nvidia = {
    includes = [ (<den/unfree> ["nvidia-x11"]) ];
    nixos = {config, pkgs, ...}: { /* NixOS config */ };
    homeManager = {pkgs, ...}: { /* Home Manager config */ };
  };
}
```

Parameterized/factory aspect:
```nix
{
  andrew.terminals.provides.alacritty = terminal: {
    homeManager = {
      programs.alacritty.settings.font.size = terminal.fontSize;
    };
  };
}
```

Flake input declaration (feeds into auto-generated `flake.nix`):
```nix
{lib, inputs, ...}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.stylix = { ... };
}
```

## Error Handling
- Use `lib.mkDefault` for overridable values
- Run `nix flake check` before committing
- Always test with `nix run .#<host> -- test` before switching

## Important Rules

1. **NEVER** edit `flake.nix` directly - auto-generated via `nix run .#write-flake`
2. **NEVER** change state version (`25.11`)
3. **ALWAYS** test with `nix run .#<host> -- test` before switching
4. **ALWAYS** format with `alejandra .` before committing
5. **ALWAYS** check lint with `statix check` and `deadnix --no-underscore --fail`
6. Use context7 and websearch to research unfamiliar NixOS/HM options
7. Prefer `includes` over `imports` for aspect composition within this repo

---

## Pre-commit Hooks

| Hook | Purpose |
|---|---|
| `alejandra` | Nix formatter |
| `deadnix` | Dead Nix code detection |
| `statix` | Nix best-practices linter |
| `nixf-diagnose` | Additional Nix diagnostics |

Excluded paths: `modules/*`, `LICENSE`, `flake.lock`, `*/flake.lock`, `.envrc`, `.direnv/*`
