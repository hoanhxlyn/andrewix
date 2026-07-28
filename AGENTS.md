# AGENTS.md — Andrewix NixOS Config

## Quick Commands

Use Justfile shortcuts (preferred). Default host = `hostname -s` (auto-detected).

```bash
just fmt          # alejandra .
just lint         # statix check + deadnix --no-underscore --fail
just check        # nix flake check . (eval errors)
just build <h>    # nix run .#<h> -- build
just boot <h>     # boot new build at next restart
just switch <h>   # nix run .#<h> -- switch
just test <h>     # nix run .#<h> -- test (needs sudo)
just vm <h>       # build + run test VM, host store, disk untouched
just update       # nix run .#write-flake && nix flake update (no commit)
just search <pkg> # nps -e <pkg> in fzf
just list-gen     # nixos-rebuild list-generations
just gc           # nix-store gc + optimise
just clean-up     # user+system GC, keep 7d (sudo)
```

Hosts: `andrew-laptop`, `andrew-pc`, `andrew-home-wsl`, `andrew-work-wsl`. Only `andrew-laptop` / `andrew-pc` are
installable (WSL hosts have no disk layout).

### No Justfile?

```bash
alejandra . && statix check && deadnix --no-underscore --fail
nix flake check .
nix run .#<host> -- build|boot|switch|test
nix run .#write-flake    # regenerate flake.nix
nix flake update         # no commit
```

## Validation Pipeline (run before commit)

```bash
just fmt && just lint && just check && just test <host>
```

`just test` needs sudo and validates the running system; `just check` catches eval errors without sudo and is the
cheaper fast-fail.

## Architecture

NixOS + Home Manager via **flake-parts** + **vic/den** dendritic framework. Auto module discovery via `vic/import-tree`.

| Path                    | Purpose                                           |
| ----------------------- | ------------------------------------------------- |
| `modules/core/`         | All aspects (NixOS + Home Manager)                |
| `modules/hosts.nix`     | Host definitions (4 hosts)                        |
| `modules/devices/`      | Per-device aspects (`workstation.nix`, `wsl.nix`) |
| `modules/defaults.nix`  | Default includes + dev shell                      |
| `modules/dendritic.nix` | Framework bootstrapping                           |
| `modules/_lib/`         | Host builder (`base.nix` + monitor layout)        |
| `hosts/<host>/_nixos/`  | Hardware configs (by-uuid fileSystems)            |
| `secrets/`              | sops-nix encrypted secrets                        |
| `config/`               | Non-Nix app configs (symlinked into `~/.config`)  |
| `flake.nix`             | **Auto-generated. DO NOT EDIT.**                  |

Host builder: `mkHost` in `modules/_lib/default.nix` composes `base.nix` with per-host data and the workstation/wsl
variant. Layout translates flat monitor attrs into niri's nested shape and sets `wsl.enable` for non-workstations.

## Conventions

- **Namespace:** `core.<name>` = all aspects (NixOS + Home Manager).
- **Composition:** `den.aspects.<name>.includes` with angle-bracket imports (`<core/sound>`, `<core/editor/nvf>`,
  `<workstation>`). Compose with `includes`, **not** `imports`, inside this repo.
- **No dead top-level args.** If a module needs nothing from the module system, write a bare attrset
  (`{ core.x = ...; }`). Only take args you actually use (`{__findFile, ...}:`, `{lib, inputs, self, ...}:`). Same for
  an aspect's `nixos`/`homeManager` fn — omit the fn wrapper when no args are used.
- **Files:** `kebab-case.nix`, **options:** `camelCase`.
- **No relative-path imports.** Take `{self, ...}` and use `import "${self}/modules/_lib/foo.nix"`.
- **Underscore dirs = not aspects.** `_nvf/`, `_nixos/`, `_lib/` are path-imported, **not** auto-discovered. Split a big
  aspect into `_<name>/*.nix` sub-configs and `import "${self}/..."` them from the aspect file (see
  `modules/core/editor/nvf.nix`).
- **`config/<tool>/`:** non-Nix app configs, one subfolder per tool (not per format). Symlink via
  `home.file."<dest>".source = "${self}/config/<tool>/<file>"` (see `modules/core/editor/cursor.nix`).
- **Booleans:** prefix with `enable`/`disable`. **Override defaults:** `lib.mkDefault`.
- **Formatter:** `alejandra`, 2-space indent, ≤100 chars.

### Module patterns

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

Flake input (declared from the aspect that needs it):

```nix
{inputs, ...}: {
  flake-file.inputs.foo = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

## Adding new aspects

`git add` the new file **before** building — nix flakes only see git-tracked files. A staged but uncommitted new aspect
produces: `error: Namespace 'core' has no aspect 'new-aspect'`.

```bash
git add modules/core/new-aspect.nix
just build <host>
```

After adding inputs or editing `flake-file.*`, regenerate:

```bash
nix run .#write-flake    # rewrites flake.nix
```

## Hard rules

1. **NEVER edit `flake.nix`** — use `nix run .#write-flake`.
2. **NEVER change `stateVersion`** (currently `26.05`, set in `modules/core/system/nix-setting.nix`).
3. **NEVER commit without** `just fmt && just lint && just check` (add `just test <host>` when feasible).
4. **User: `andrew`, system: `x86_64-linux`.**
5. **No unit tests** — validate via `just build` + `just test <host>`.
6. **Tools installed via Nix** (`modules/core/`) — no pre-commit hooks.
7. **Research unfamiliar NixOS/HM options** with `context7` + `websearch` before guessing.
8. **Activate `caveman` skill** — terse output mode is the default.

## Operational gotchas

- **Disko on live hosts:** `disko.enableConfig = false` in `modules/core/hardware/disko.nix:17` — disko provides the
  install scripts but does **not** own the running ext4 systems' `fileSystems`. At a real btrfs reinstall, flip to
  `true` AND drop the by-uuid `fileSystems`/`swapDevices` blocks from `hosts/<host>/_nixos/hardware-configuration.nix`.
- **First-boot password:** `admin123` (set in `modules/_lib/base.nix`). Change with `passwd` after install. The default
  is also used for `just vm`.
- **WSL PATH:** `modules/devices/wsl.nix:20` disables WSL interop `$PATH` because Windows PATH lives on a slow 9P/DrvFs
  mount. Invoke `.exe`s by absolute path; `wsl-open` wrapper handles explorer.exe's spurious non-zero exit.
- **Secrets:** only on `andrew-laptop` / `andrew-pc`. Decrypt with the shared age key at `~/.config/sops-nix/keys.txt`
  on each host. Edit via `sops secrets/secrets.yaml`; declare new secrets in `modules/core/services/sync/sops.nix` under
  `sops.secrets`.
- **Auto GC:** `nix.gc.automatic` runs daily, `--delete-older-than 7d` (see `nix-setting.nix`). `just clean-up` does the
  same on demand (sudo).

## Dev shell

`.envrc` runs `use flake` (direnv). Auto-loads via `.direnv/`. The dev shell (`just`-style `nix develop`) provides:
`gh`, `alejandra`, `statix`, `deadnix`, `just`.
