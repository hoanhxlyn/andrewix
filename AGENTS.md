# AGENTS.md — Andrewix NixOS Config

## Quick Commands

Use Justfile shortcuts (preferred):

```bash
just fmt          # alejandra .
just lint         # statix check + deadnix --no-underscore --fail
just switch <h>   # nix run .#<host> -- switch
just test <h>     # nix run .#<host> -- test (needs sudo)
just build <h>    # nix run .#<host> -- build
just update       # nix flake update --commit-lock-file (commits lock!)
just search <pkg> # nps -e <pkg>
just gc           # nix store gc
just clean-up     # sudo nix-collect-garbage --delete-old
```

Default host = `hostname -s` (auto-detected). Hosts: `andrew-laptop`, `andrew-pc`, `andrew-home-wsl`, `andrew-work-wsl`.
Raw commands when justfile unavailable: ```bash nix run .#write-flake # Regenerate flake.nix nix flake update --flake
. # Update inputs (no commit)

````bash

## Validation Pipeline (Run Before Commit)

```bash
just fmt && just lint && just check && just test <host>
````

`just test` requires sudo.

## Architecture

NixOS + Home Manager via **flake-parts** + **vic/den** dendritic framework. Auto module discovery via `vic/import-tree`.

| Dir                     | Purpose                                        |
| ----------------------- | ---------------------------------------------- |
| `modules/core/`         | All aspects (NixOS + Home Manager)             |
| `modules/hosts.nix`     | Host definitions (4 hosts)                     |
| `modules/devices/`      | Per-device aspects (laptop.nix, wsl.nix)       |
| `modules/defaults.nix`  | Default includes for all hosts                 |
| `modules/dendritic.nix` | Framework bootstrapping                        |
| `hosts/<host>/_nixos/`  | Hardware configs (filesystems, kernel modules) |
| `secrets/`              | sops-nix encrypted secrets                     |
| `config/`               | Non-Nix app configs                            |
| `flake.nix`             | **Auto-generated. DO NOT EDIT.**               |

## Conventions

- **Namespace:** `core.<name>` = all aspects (NixOS + Home Manager)
- **Composition:** `den.aspects.<name>.includes` using angle-bracket imports
- **Compose aspects with `includes`** not `imports` within this repo
- **No dead top-level args:** if a module file needs nothing from the module system, write a bare attrset
  (`{ core.x = ...; }`) — do **not** wrap it in `_:` or `{...}:`. Only take args you use (e.g. `{__findFile, ...}:`,
  `{lib, inputs, ...}:`). Same for an aspect's `nixos`/`homeManager` fn — omit the fn wrapper when no args are used.
- **Files:** `kebab-case.nix`, **Options:** `camelCase`
- **No relative-path imports** (`../../../_lib/foo.nix`) — take `{self, ...}` and use
  `import "${self}/modules/_lib/foo.nix"`
- **Underscore dirs = not aspects:** `_nvf/`, `_nixos/`, `_lib/` are path-imported, **not** auto-discovered. Split a big
  aspect into `_<name>/*.nix` sub-configs and `import "${self}/modules/.../_<name>/foo.nix"` them from the aspect file
  (see `modules/core/editor/nvf.nix`).
- **`config/<tool>/`:** non-Nix app configs, one subfolder per tool (not per format). Symlink into place via
  `home.file."<dest>".source = "${self}/config/<tool>/<file>"` (see `modules/core/editor/cursor.nix`).
- **Booleans:** prefix with `enable`/`disable`
- **Override defaults:** `lib.mkDefault`
- **Formatter:** `alejandra`, 2-space indent, ≤100 chars hard limit

### Module Patterns

Simple aspect:

```nix
{
  core.sound.nixos = {
    services.pipewire.enable = true;
  };
}
```

With includes + nixos + homeManager:

```nix
{__findFile, ...}: {
  core.aspect = {
    includes = [ (<den/dep> ["pkg-name"]) ];
    nixos = {config, pkgs, ...}: { /* NixOS */ };
    homeManager = {pkgs, ...}: { /* Home Manager */ };
  };
}
```

Flake input:

```nix
{lib, inputs, ...}: {
  flake-file.inputs.foo = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

## Adding New Aspects

When creating a new `.nix` file in `modules/`, **always `git add` it before building**:

```bash
git add modules/core/new-aspect.nix
just build <host>
```

Nix flakes only see git-tracked files. A new file that hasn't been staged yet will cause:
`error: Namespace 'core' has no aspect 'new-aspect'`

## Hard Rules

1. **NEVER edit `flake.nix`** — use `nix run .#write-flake`
2. **NEVER change stateVersion** (currently `26.05`)
3. **NEVER commit without** `just fmt && just lint && just build`
4. User: `andrew`, System: `x86_64-linux`
5. No unit tests — validate via `just build` + `just test <host>`
6. Tools installed via Nix (`modules/core/`) — no pre-commit hooks
7. Research unfamiliar NixOS/HM options with context7 + websearch
8. Activate caveman skill **always**

## Garbage Collection

```bash
just gc        # User store GC
just clean-up  # System-wide GC + delete old gens (sudo)
```
