# AGENTS.md — Andrewix NixOS Config

## Quick Commands

Use Justfile shortcuts (preferred). Default host = `hostname -s` (auto-detected).

```bash
just fmt          # alejandra .
just lint         # statix check + deadnix --no-underscore --fail
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

Hosts: `asus-vivo14`, `asus-rog-gl552vx`, `home-pc`, `home-wsl`, `work-wsl`. Only
`asus-vivo14` / `asus-rog-gl552vx` / `home-pc` are installable (WSL hosts have no disk layout).

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
just fmt && just lint && just test <host>
```

`just test` needs sudo and validates the running system. Build with `just build <host>` to catch eval errors without
sudo (slower than the deprecated `just check`, but accurate).

## Architecture

NixOS + Home Manager via **flake-parts** + **vic/den** dendritic framework. Auto module discovery via `vic/import-tree`.

| Path                    | Purpose                                           |
| ----------------------- | ------------------------------------------------- |
| `modules/core/`         | All aspects (NixOS + Home Manager)                |
| `modules/hosts.nix`     | Host definitions (5 hosts) + host→variant wiring  |
| `modules/schema.nix`    | Host facts → `den.schema.host` (`_lib/facts.nix`) |
| `modules/devices/`      | Variant aspects (`workstation.nix`, `wsl.nix`)    |
| `modules/defaults.nix`  | Default includes + dev shell                      |
| `modules/dendritic.nix` | Framework bootstrapping                           |
| `modules/_settings.nix` | Shared host settings (path-imported by `mkHost`)  |
| `modules/_lib/`         | Host builder (`mk-host.nix`, `facts.nix`)         |
| `secrets/`              | sops-nix encrypted secrets                        |
| `config/`               | Non-Nix app configs (symlinked into `~/.config`)  |
| `flake.nix`             | **Auto-generated. DO NOT EDIT.**                  |

Host builder: `mkHost` in `modules/_lib/mk-host.nix` composes `_settings.nix` with per-host data and the workstation/wsl
variant. Layout translates flat monitor attrs into niri's nested shape and sets `wsl.enable` for non-workstations.

**Host facts** (set in `modules/hosts.nix`). The single definition is `modules/_lib/facts.nix`; `modules/schema.nix`
feeds it to `den.schema.host` (types, defaults), `mkHost` rejects unknown fact names against it, and cross-fact checks
are `assertions` in `modules/core/hardware/default.nix`:

| Fact              | Values / meaning                                                                 |
| ----------------- | -------------------------------------------------------------------------------- |
| `formFactor`      | `desktop` (default) \| `laptop`; derives `host.isLaptop`                         |
| `gpu`             | list of `intel` \| `nvidia`; both = hybrid                                       |
| `nvidiaPrime`     | `{intelBusId, nvidiaBusId}`; hybrid only; `null` = PRIME off + build warning     |
| `bootLoader`      | `systemd-boot` (default) \| `grub`                                               |
| `storage`         | `{layout = "single" \| "multi"; swap = "24G";}`; `multi` = nixos/works/entertainment |
| `chargeThreshold` | `{start, stop}` battery limits (laptop only); `null` = unmanaged                 |
| `enableGaming`    | include `<core.gaming>`                                                          |

Aspects are chosen from facts, **never from a hostname**: hardware aspects in `modules/core/hardware/default.nix`
(`power-manager`, `intel-vaapi`, `nvidia`), gaming in `modules/devices/workstation.nix`. The workstation/wsl variant per
host is generated in `hosts.nix` via `provides.to-users`.

**Adding a device:** add one `mkHost` entry in `hosts.nix` with its facts and monitors (keyed by connector name), and
nothing else: `install.fish` reads `flake.installableHosts` (all non-WSL hosts). No other file should mention the
hostname.

## Conventions

- **Namespace:** `core.<name>` = all aspects (NixOS + Home Manager).
- **Composition:** `den.aspects.<name>.includes` with angle-bracket imports (`<core/sound>`, `<core/editor/nvf>`,
  `<workstation>`). Compose with `includes`, **not** `imports`, inside this repo.
- **No dead top-level args.** If a module needs nothing from the module system, write a bare attrset
  (`{ core.x = ...; }`). Only take args you actually use (`{__findFile, ...}:`, `{lib, inputs, self, ...}:`). Same for
  an aspect's `nixos`/`homeManager` fn — omit the fn wrapper when no args are used.
- **Files:** `kebab-case.nix`, **options:** `camelCase`.
- **No relative-path imports.** Take `{self, ...}` and use `import "${self}/modules/_lib/foo.nix"`. **Exception:**
  `hosts.nix`, `schema.nix` and `_lib/mk-host.nix` run while the flake outputs are being computed, so `${self}`
  there is infinite recursion — those three use relative imports.
- **Underscore dirs = not aspects.** `_nvf/`, `_nwm/`, `_lib/` are path-imported, **not** auto-discovered. Split a big
  aspect into `_<name>/*.nix` sub-configs and `import "${self}/..."` them from the aspect file (see
  `modules/core/editor/nwm.nix`).
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
3. **NEVER commit without** `just fmt && just lint` (add `just test <host>` when feasible).
4. **User: `andrew`, system: `x86_64-linux`.**
5. **No unit tests** — validate via `just build` + `just test <host>`.
6. **Tools installed via Nix** (`modules/core/`) — no pre-commit hooks.
7. **Research unfamiliar NixOS/HM options** with `context7` + `websearch` before guessing.
8. **No system Python** — machine has no `python`/`python3`. Run Python via `uv run` (e.g. `uv run python script.py`,
   `uv run --with <pkg> ...`).

## Operational gotchas

- **Disko owns the layout:** `disko.enableConfig = true` in `modules/core/hardware/disko.nix` — disko provides
  `fileSystems`/`swapDevices`/`boot.resumeDevice` (xfs root, dedicated swap partition, hibernate resume) for all
  physical hosts; layout and swap size come from the `storage` fact. The per-host `hosts/<host>/_nixos/` configs are
  gone; hardware boot bits (initrd `vmd`/`ahci`/`nvme`, kvm, microcode) live in `modules/core/hardware/bootable.nix`,
  shared by the Intel workstations; the loader comes from the `bootLoader` fact. Target disks are picked at install time
  by `install.fish`, so the `/dev/nvme0n1` in `disko.nix` is only a default.
- **Hybrid GPU (`asus-rog-gl552vx`, GTX 950M):** `nvidiaPrime` bus IDs are unset until you fill them from
  `lspci -D -d ::03xx` after install (see the `TODO`s in `hosts.nix`). niri runs on the Intel iGPU; games use the
  nvidia dGPU via PRIME offload (`nvidia-offload <cmd>`, e.g. as a Steam launch option). PRIME sync is X11-only and is
  not used. Verify connector names with `niri msg outputs`; HDMI ports wired to the nvidia GPU may behave differently.
- **Charge limit:** `core.hardware.power-manager` sets TLP thresholds and the asus_wmi workaround only when the host
  declares `chargeThreshold` (X1405VA, `asus-vivo14`).
- **First-boot password:** the installer (`install.fish`) prompts for it and sets it with `nixos-enter` before you
  reboot; no default password ships in the repo. A known `admin123` survives only inside `virtualisation.vmVariant`
  (`modules/core/hardware/disko.nix`) for `just vm`. Machines installed before this still hold the old bootstrap
  password — check with `sudo passwd -S andrew` and run `passwd` if it shows `P`.
- **WSL PATH:** `modules/devices/wsl.nix:20` disables WSL interop `$PATH` because Windows PATH lives on a slow 9P/DrvFs
  mount. Invoke `.exe`s by absolute path; `wsl-open` wrapper handles explorer.exe's spurious non-zero exit.
- **Secrets:** only on `asus-vivo14` / `asus-rog-gl552vx` / `home-pc`. Decrypt with the shared age key
  at `~/.config/sops-nix/keys.txt` on each host. Edit via `sops secrets/secrets.yaml`; declare new secrets in
  `modules/core/services/sync/sops.nix` under `sops.secrets`.
- **Auto GC:** `nix.gc.automatic` runs daily, `--delete-older-than 7d` (see `nix-setting.nix`). `just clean-up` does the
  same on demand (sudo).

## Dev shell

`.envrc` runs `use flake` (direnv). Auto-loads via `.direnv/`. The dev shell (`just`-style `nix develop`) provides:
`gh`, `alejandra`, `statix`, `deadnix`, `just`.
