# Andrewix - NixOS & Home Manager Configuration

Personal NixOS + Home Manager configuration using flake-parts with a dendritic
(aspect-first) architecture and automatic module discovery via `vic/import-tree`
+ `vic/den`.

## Quick Start

```bash
# Apply configuration (pick your host)
nix run .#andrew-laptop -- switch
nix run .#andrew-pc -- switch

# Validate before committing (requires sudo)
nix run .#<host> -- test

# Update all flake inputs
nix flake update --flake .

# Check for evaluation errors
nix flake check
```

## Architecture

| Path | Purpose |
|---|---|
| `modules/core/` | System-level aspects (NixOS config) |
| `modules/my/` | User-level aspects (Home Manager config) |
| `modules/defaults.nix` | Default includes + state version for all hosts |
| `modules/devices.nix` | Device-level aspect composition |
| `modules/hosts.nix` | Host definitions (`andrew-laptop`, `andrew-pc`) |
| `modules/users/andrew.nix` | User identity + included aspects |
| `hosts/<host>/_nixos/` | Hardware-specific configs (filesystems, kernel modules) |
| `config/` | Non-Nix application configs |
| `flake.nix` | Auto-generated entry point (DO NOT EDIT) |

Any `.nix` file under `modules/` is auto-discovered via `vic/import-tree`.
Aspects are composed through `den.aspects.<name>.includes` using angle-bracket
imports like `<core/sound>` or `<my/shell>`.

## Development Workflow

1. **Edit** the relevant `.nix` file under `modules/core/` or `modules/my/`
2. **Add features** by creating new `.nix` files in the appropriate subdirectory
3. **Validate** before committing:

```bash
nix flake check          # Evaluation errors
alejandra .              # Format
statix check             # Lint
deadnix --no-underscore --fail  # Dead code
```

See `AGENTS.md` for detailed conventions, module patterns, and important rules.
