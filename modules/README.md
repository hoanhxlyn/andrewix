# modules/

The NixOS and Home Manager configuration. It is built with flake-parts and the
[den](https://github.com/denful/den) dendritic framework. Every `.nix` file here is discovered
automatically by `import-tree`, except files and folders whose names start with `_`.

Non-Nix app configs (JSON, YAML, scripts, images) do not belong here. They live in `../config/`.

## Layout

| Path                | Purpose                                                              |
| ------------------- | -------------------------------------------------------------------- |
| `defaults.nix`      | Bootstrapping, den and Home Manager inputs, default includes         |
| `namespace.nix`     | Declares the `core` namespace and the angle-bracket lookup           |
| `hosts.nix`         | Host definitions and the host to variant wiring                      |
| `schema.nix`        | Host facts as `den.schema.host` (types and defaults)                 |
| `iso.nix`           | Installer ISO                                                        |
| `_settings.nix`     | Shared host settings, path-imported and not auto-discovered          |
| `core/`             | All aspects, NixOS and Home Manager together                         |
| `devices/`          | Variant aspects: `workstation.nix` and `wsl.nix`                     |
| `_lib/`             | Helpers, path-imported and not auto-discovered                       |

`_lib/` contains:

| File               | Purpose                                                            |
| ------------------ | ------------------------------------------------------------------ |
| `mk-host.nix`      | `mkHost`: builds one host from settings, facts and monitors        |
| `facts.nix`        | The single definition of host facts                                |
| `blurred-image.nix`| Blurred wallpaper helper                                           |

## How a host is built

1. `hosts.nix` calls `mkHost` once per host with that host's facts and monitors.
2. `mkHost` starts from `_settings.nix`, applies the host's overrides, and rejects fact names
   that `_lib/facts.nix` does not know.
3. The result is the `host` attrset. Any aspect can read it as `{host, ...}`.
4. Each host gets a variant, chosen from the facts and never from the hostname: `workstation` for
   physical machines, `wsl` for WSL. The variant includes the aspects under `core/`.

## Settings and facts

- **Settings** (`_settings.nix`) are shared preferences, grouped like a desktop Settings app:
  `appearance`, `input`, `accessibility`, `defaults`, `locale`, `terminal`, `login`. A host may
  override any section, and sections merge key by key.
- **Facts** (`_lib/facts.nix`) describe the machine: `formFactor`, `gpu`, `bootLoader`, `storage`,
  `chargeThreshold`, `enableGaming`, and so on. They are typed through `schema.nix`.

Settings are pure data. Anything that needs `pkgs`, such as fonts, cursor and icon packages, stays
in the aspect that uses it.

## Adding an aspect

Aspects live under `core/` and are named `core.<name>`. Compose them with `includes`, not
`imports`.

```nix
{
  core.sound.nixos = {
    services.pipewire.enable = true;
  };
}
```

With both NixOS and Home Manager parts and an include:

```nix
{__findFile, ...}: {
  core.aspect = {
    includes = [(<den/dep> ["pkg-name"])];
    nixos = {pkgs, ...}: {};
    homeManager = {pkgs, ...}: {};
  };
}
```

To use a new aspect, add it to a group under `core/`, or include it from `devices/workstation.nix`
or `devices/wsl.nix`.

Run `git add` on the new file before building. Flakes only see files tracked by git, and an
untracked aspect fails with `Namespace 'core' has no aspect '<name>'`.

## Conventions

- Files are `kebab-case.nix`. Options are `camelCase`.
- Booleans start with `enable` or `disable`. Override defaults with `lib.mkDefault`.
- Take only the arguments you use. A module that needs nothing is a bare attrset.
- No relative-path imports. Take `{self, ...}` and use `import "${self}/modules/_lib/foo.nix"`.
- Split a large aspect into `_<name>/*.nix` and import the pieces from the aspect file.
- Choose aspects from facts, never from a hostname.
- Format with `just fmt` (alejandra, 2-space indent, at most 100 characters) and check with
  `just lint`.

See `../AGENTS.md` for the full rules and the build and test commands.
