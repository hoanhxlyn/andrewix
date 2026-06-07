# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
just fmt              # Format: alejandra .
just lint             # statix check + deadnix --no-underscore --fail
just check            # nix flake check .
just build [host]     # Build (no switch)
just test [host]      # Dry activate (requires sudo)
just switch [host]    # Apply to system
just update           # Regenerate flake.nix + nix flake update
just gc               # User store GC
just clean-up         # System GC + delete old generations (sudo)
```

Default host auto-detected via `hostname -s`. Hosts: `andrew-laptop`, `andrew-pc`, `andrew-home-wsl`, `andrew-work-wsl`.

**Validation pipeline before commit:**
```bash
just fmt && just lint && just check && just test <host>
```

Without Justfile: `nix run .#<host> -- switch|test|build`

## Architecture

NixOS + Home Manager config using **flake-parts** + **vic/den** dendritic framework. Modules are auto-discovered via `vic/import-tree` — no manual import registration needed.

| Path | Purpose |
|------|---------|
| `modules/core/` | System-level aspects → NixOS config |
| `modules/my/` | User-level aspects → Home Manager config |
| `modules/devices/` | Per-device aspects (workstation, wsl) |
| `modules/hosts.nix` | Host definitions (4 hosts) with per-host monitor/terminal params |
| `modules/defaults.nix` | Default includes applied to all hosts |
| `hosts/<host>/_nixos/` | Hardware configs (filesystems, kernel modules) |
| `disko/<host>/` | Disk partitioning configs |
| `secrets/secrets.yaml` | sops-nix encrypted secrets (safe to commit) |
| `config/` | Non-Nix app configs (neovim lua, vscode JSON, etc.) |
| `flake.nix` | **Auto-generated. DO NOT EDIT.** |

### Module Patterns

Simple aspect (NixOS only):
```nix
{
  core.sound.nixos = {
    services.pipewire.enable = true;
  };
}
```

With includes and both systems:
```nix
{__findFile, ...}: {
  core.aspect = {
    includes = [ (<den/dep> ["pkg-name"]) ];
    nixos = {config, pkgs, ...}: { /* NixOS options */ };
    homeManager = {pkgs, ...}: { /* Home Manager options */ };
  };
}
```

Factory (parameterized, e.g. per-terminal config):
```nix
{
  my.category.provides.name = param: {
    homeManager = { /* use param */ };
  };
}
```

Adding a flake input (triggers `nix run .#write-flake` to regenerate flake.nix):
```nix
{lib, inputs, ...}: {
  flake-file.inputs.foo = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

### Composition

- Always use `includes` with angle-bracket imports (`<core/sound>`, `<my/shell>`, `<my/cli/essentials>`) — **never use `imports`** within this repo
- Host-specific composition lives in `modules/hosts.nix` under `<host>.provides.to-users.includes`
- Namespace: `core.<name>` = NixOS aspects, `my/<cat>` = Home Manager aspects, `my/<cat>.provides.<name>` = factory aspects

## Secrets

Encrypted with sops-nix using a shared age key (`~/.config/sops-nix/keys.txt`). Only available on workstation hosts (not WSL).

- **Edit secrets:** `sops secrets/secrets.yaml`
- **Add a new secret:** edit `secrets/secrets.yaml` AND declare it in `modules/my/sync/sops.nix` under `sops.secrets`

## Hard Rules

1. **NEVER edit `flake.nix`** — run `nix run .#write-flake` to regenerate after modifying inputs
2. **NEVER change `stateVersion`** (currently `26.05`)
3. **NEVER commit without** `just fmt && just lint && just build`
4. User: `andrew`, system: `x86_64-linux`
5. Validation is via `just build` + `just test <host>` — no unit tests
6. Formatting: `alejandra`, 2-space indent, ≤100 chars per line
7. File names: `kebab-case.nix` — option names: `camelCase` — booleans prefixed with `enable`/`disable`
8. Override defaults with `lib.mkDefault`
9. Research unfamiliar NixOS/Home Manager options with context7 + websearch before writing
