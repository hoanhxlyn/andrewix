# AGENTS.md - Guidelines for Coding Agents

## Build/Lint/Test Commands

### Apply Configuration
```bash
nix run .#andrew-laptop -- switch   # Apply config to andrew-laptop
nix run .#andrew-pc -- switch       # Apply config to andrew-pc
nix run .#<host> -- test             # Validate config before commit (requires sudo)
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
```

Tools are installed via Nix (`modules/my/cli.nix`), not via pre-commit hooks.

### Regenerate Flake
```bash
nix run .#write-flake               # Regenerate flake.nix (DO NOT edit manually)
```

**Note:** No unit tests - validation via `nix run .#<host> -- test` and `nix flake check`.

## Project Architecture

NixOS + Home Manager config using **flake-parts** with a **dendritic (aspect-first)
architecture** and automatic module discovery via `vic/import-tree` + `vic/den`.

### Directory Structure
```
├── flake.nix           # Auto-generated (DO NOT EDIT)
├── flake.lock          # Pinned dependency lockfile
├── modules/
│   ├── dendritic.nix   # Dendritic module loader (vic/den framework)
│   ├── namespace.nix   # Namespace definitions (core, my)
│   ├── defaults.nix    # Default includes for all hosts
│   ├── hosts.nix       # Host definitions (andrew-laptop, andrew-pc)
│   ├── devices.nix     # Device-level aspect composition (andrew-laptop)
│   ├── core/           # System-level aspects (NixOS)
│   ├── my/             # User-level aspects (Home Manager)
│   └── users/          # User identity + aspect includes (andrew.nix)
├── hosts/              # Hardware-specific configs
│   └── <host>/_nixos/  # filesystems.nix, hardware-configuration.nix
└── config/             # Non-Nix application configs
```

### Namespace Conventions
- `core.<name>` — System-level aspect; configures NixOS
- `my/<category>` — User-level aspects; configures Home Manager
- `my/<category>.provides.<name>` — Parameterized/factory aspects
- `den.aspects.andrew.includes` — User composition (in `users/andrew.nix`)
- `den.aspects.<hostname>` — Device composition (in `devices.nix`)

### Key Variables
- Username: `andrew`
- System: `x86_64-linux`
- State Version: `26.05` (DO NOT MODIFY)

---

## Nix Code Style

### Formatting
- **Formatter:** `alejandra`
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
2. **NEVER** change state version (`26.05`)
3. **ALWAYS** test with `nix run .#<host> -- test` before switching
4. **ALWAYS** format with `alejandra .` before committing
5. **ALWAYS** check lint with `statix check` and `deadnix --no-underscore --fail`
6. Use context7 and websearch to research unfamiliar NixOS/HM options
7. Prefer `includes` over `imports` for aspect composition within this repo
