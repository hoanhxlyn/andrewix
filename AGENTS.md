# AGENTS.md — Andrewix NixOS Config

## Quick Commands

Use Justfile shortcuts. Best way. Default host = `hostname -s` (auto-detect).

```bash
just fmt          # alejandra .
just lint         # statix + deadnix + comment markers
just build <h>    # nix run .#<h> -- build
just boot <h>     # boot new build at next restart
just switch <h>   # nix run .#<h> -- switch
just test <h>     # nix run .#<h> -- test (needs sudo)
just vm <h>       # build + run test VM, host store, disk untouched
just update       # nix run .#write-flake && nix flake update (no commit)
just search <pkg> # nps -e <pkg> in fzf
just list-gen     # nixos-rebuild list-generations
just gc           # wipe old system gens + store gc
just clean-up     # user+system GC, keep 7d (sudo)
```

Hosts: `asus-vivo14`, `asus-rog-gl552vx`, `msi-gf63`, `home-pc`, `home-wsl`, `work-wsl`. Only non-WSL hosts installable — WSL hosts have no disk layout.

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

`just test` need sudo, check running system. Build with `just build <host>` to catch eval error without sudo (slower than old `just check`, but accurate).

## Architecture

NixOS + Home Manager via **flake-parts** + **vic/den** dendritic framework. Module auto-found via `vic/import-tree`.

| Path                    | Purpose                                           |
| ----------------------- | ------------------------------------------------- |
| `modules/core/`         | All aspects (NixOS + Home Manager)                |
| `modules/hosts.nix`     | Host definitions (6 hosts) + host→variant wiring  |
| `modules/schema.nix`    | Host facts → `den.schema.host` (`_lib/host-facts.nix`) |
| `modules/devices/`      | Variant aspects (`workstation`, `homelab`, `wsl`)  |
| `modules/defaults.nix`  | Default includes + dev shell                      |
| `modules/dendritic.nix` | Framework bootstrapping                           |
| `modules/_settings.nix` | Shared host settings (path-imported by `mkHost`)  |
| `modules/_lib/`         | Host builder (`mk-host.nix`, `host-facts.nix`)    |
| `secrets/`              | sops-nix encrypted secrets                        |
| `config/`               | Non-Nix app configs (symlinked into `~/.config`)  |
| `flake.nix`             | **Auto-generated. DO NOT EDIT.**                  |

Host builder: `mkHost` in `modules/_lib/mk-host.nix` compose `_settings.nix` + per-host data + workstation/homelab/wsl variant. Layout turn flat monitor attrs into niri nested shape, set variant flag (`homelab.enable` for homelab hosts, `wsl.enable` for WSL hosts).

**Host facts** (set in `modules/hosts.nix`). One definition live in `modules/_lib/host-facts.nix`; `modules/schema.nix` feed it to `den.schema.host` (types, defaults), `mkHost` reject unknown fact names against it, and cross-fact checks be `assertions` in `modules/core/hardware/default.nix`:

| Fact              | Values / meaning                                                                 |
| ----------------- | -------------------------------------------------------------------------------- |
| `chassis`         | `desktop` (default) \| `laptop`; derives `host.isLaptop`                         |
| `cpu`             | `intel` (default) \| `amd`; kvm module + microcode in `core.hardware.bootable`   |
| `gpu`             | list of `{vendor = intel \| nvidia; kind = integrated \| discrete; busId ? null}`; integrated Intel + NVIDIA = hybrid. `busId` is the PRIME form `PCI:bus@domain:dev:fn` |
| `bootLoader`      | `systemd-boot` (default) \| `grub` \| `limine`                                       |
| `storage`         | `{layout = "single" \| "multi" \| "dual"; swap = "24G";}`; `multi` = nixos/works/entertainment, `dual` = root + data disk |
| `chargeThreshold` | `{start, stop, msiEc}` battery limits; laptops default to 70/80, others `null` = unmanaged |
| `enableGaming`    | include `<core.gaming>`                                                          |

Aspects come from facts, **never from hostname**: hardware aspects in `modules/core/hardware/default.nix` (`power-manager`, `intel-gpu`, `nvidia`), gaming in `modules/devices/workstation.nix`. Variant per host generated in `hosts.nix` via `provides.to-users`.

**Adding a device:** add one `mkHost` entry in `hosts.nix` with facts and monitors (keyed by connector name), nothing else: `install.fish` read `flake.installableHosts` (all non-WSL hosts). No other file mention hostname.

`monitors` take optional `order = ["eDP-1" "HDMI-A-1"]` for left→right placement (positions computed in logical pixels; without it, connector name order). `is-primary` only mark output niri focus at startup, never where it sit.

## Conventions

- **Namespace:** `core.<name>` = all aspects (NixOS + Home Manager).
- **Composition:** `den.aspects.<name>.includes` with angle-bracket imports (`<core/sound>`, `<core/editor/nvf>`,
  `<workstation>`). Compose with `includes`, **not** `imports`, in this repo.
- **No dead top-level args.** Module need nothing from module system → write bare attrset (`{ core.x = ...; }`). Only take args actually used (`{__findFile, ...}:`, `{lib, inputs, self, ...}:`). Same for aspect's `nixos`/`homeManager` fn — omit fn wrapper when no args used.
- **Files:** `kebab-case.nix`, **options:** `camelCase`.
- **No relative-path imports.** Take `{self, ...}` and use `import "${self}/modules/_lib/foo.nix"`. **Exception:** `hosts.nix`, `schema.nix` and `_lib/mk-host.nix` run while flake outputs being computed, so `${self}` there = infinite recursion — those three use relative imports.
- **Underscore dirs = not aspects.** `_nvf/`, `_nwm/`, `_lib/` path-imported, **not** auto-discovered. Split big aspect into `_<name>/*.nix` sub-configs and `import "${self}/..."` them from aspect file (see `modules/core/editor/nwm.nix`).
- **`config/<tool>/`:** non-Nix app configs, one subfolder per tool (not per format). Symlink via `home.file."<dest>".source = "${self}/config/<tool>/<file>"` (see `modules/core/editor/cursor.nix`).
- **Booleans:** prefix with `enable`/`disable`. **Override defaults:** `lib.mkDefault`.
- **Formatter:** `alejandra`, 2-space indent, ≤100 chars.
- **Comments:** marker-tagged comment use exactly `TODO:` (actionable, or waiting on upstream — name trigger), `NOTE:` (explanation) or `README:` (reference link). Never invent marker (`FIXME`, `HACK`, `XXX`, `shortcut:`, …); `just lint` reject those. Plain prose explaining *why* fine.
- **Attribute nesting:** nest option group only when it have ≥4 children; 1–3 children → write dotted paths (`services.pipewire.enable = true;`, not `services.pipewire = { enable = true; };`). Only binding values count: `core`/`den`/`flake-file` skeletons keep shape, and so do aspect's `nixos`/`homeManager` body itself, `let` bindings (no dotted names there), function arguments (`mkOption { … }`), host data (`modules/hosts.nix`, `_lib/*-facts.nix`) and sets with `inherit`/`rec`/`${…}` names — everything inside module body follow rule. `x = { a = 1; };` and `x.a = 1;` be same path, so this spelling only; enforce with `just attr` (`just attr --check` to fail instead of rewrite).

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

Flake input (declared from aspect that need it):

```nix
{inputs, ...}: {
  flake-file.inputs.foo = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

## Adding new aspects

`git add` new file **before** build — nix flakes only see git-tracked files. Staged but uncommitted new aspect make: `error: Namespace 'core' has no aspect 'new-aspect'`.

```bash
git add modules/core/new-aspect.nix
just build <host>
```

After add inputs or edit `flake-file.*`, regenerate:

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
7. **Never trust memory.** Verify every factual claim (options, flags, config keys) before assert, use combo: `deepwiki` (source-level) + `context7` (docs) + web search (`exa`). Cross-check between them — they contradict each other; raw source (`curl` + `grep` exact packaged rev) beat any summary.
8. **No system Python** — machine have no `python`/`python3`. Run Python via `uv run` (e.g. `uv run python script.py`, `uv run --with <pkg> ...`).

## Operational gotchas

- **Disko own the layout:** `disko.enableConfig = true` in `modules/core/hardware/disko.nix` — disko provide `fileSystems`/`swapDevices`/`boot.resumeDevice` (xfs root, dedicated swap partition, hibernate resume) for all physical hosts; layout and swap size come from `storage` fact. Per-host `hosts/<host>/_nixos/` configs gone; hardware boot bits (initrd `vmd`/`ahci`/`nvme`, kvm, microcode) live in `modules/core/hardware/bootable.nix`, shared by Intel workstations; loader come from `bootLoader` fact. Target disks picked at install time by `install.fish`, so `/dev/nvme0n1` in `disko.nix` only be default.
- **Hybrid GPU (`msi-gf63`, GTX 1650 Mobile):** `gpu` entries' `busId`s filled in from `lspci -D -d ::03xx` (see `hosts.nix`); hybrid host without them get PRIME off + build warning. niri run on Intel iGPU; games use nvidia dGPU via PRIME offload (`nvidia-offload <cmd>`, e.g. as Steam launch option). PRIME sync X11-only, not used. Verify connector names with `niri msg outputs`; HDMI ports wired to nvidia GPU may behave different.
- **Charge limit:** `core.hardware.power-manager` set TLP thresholds and asus_wmi workaround for any laptop (default 70/80; `asus-vivo14` and others override it) unless host set `chargeThreshold = null`. Hosts whose firmware missing from in-tree msi-ec allowlist (GF63 Thin 10SC, `msi-gf63`) set `msiEc = true`: aspect then pull out-of-tree `boot.kernelPackages.msi-ec` and write threshold to `BAT1/charge_control_end_threshold`.
- **First-boot password:** installer (`install.fish`) prompt for it and set with `nixos-enter` before reboot; no default password in repo. Known `admin123` survive only inside `virtualisation.vmVariant` (`modules/core/hardware/disko.nix`) for `just vm`. Machines installed before this still hold old bootstrap password — check with `sudo passwd -S andrew` and run `passwd` if it show `P`.
- **WSL PATH:** `modules/devices/wsl.nix` disable WSL interop `$PATH` because Windows PATH live on slow 9P/DrvFs mount. Invoke `.exe`s by absolute path; `wsl-open` wrapper handle explorer.exe's spurious non-zero exit.
- **Secrets:** sops aspect included on every workstation (via `<core.services>`), homelab and WSL host. Decrypt with shared age key at `~/.config/sops-nix/keys.txt`, which must be present on each host. Edit via `sops secrets/secrets.yaml`; declare new secrets in `modules/core/services/sync/sops.nix` under `sops.secrets`.
- **GC manual:** no `nix.gc` timer; run `just gc` (wipe old system gens + store gc, need sudo).

## Dev shell

`.envrc` run `use flake` (direnv). Auto-load via `.direnv/`. Dev shell (`just`-style `nix develop`) provide: `gh`, `alejandra`, `statix`, `deadnix`, `just`.