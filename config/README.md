# config/

Non-Nix files only. Nothing in this directory is evaluated as Nix: no `.nix` files, no modules, no
options. Anything that needs `pkgs`, `lib` or the `host` attrset belongs in `modules/`.

Files here are plain app configs (JSON, YAML, TOML, shell scripts, text art, images) that the Nix
modules import or symlink. They are the source of truth for each tool and are edited here, not in
`~/.config`.

## Layout

One subfolder per tool, not per file format:

```text
config/
├── arts/        # text art used by fastfetch
├── background/  # wallpapers (appearance.wallpaper, source = "local")
├── cursor/      # settings.json, keybindings.json
├── omp/         # oh-my-posh themes
└── <tool>/      # add new tools here
```

## How files get used

A module in `modules/core/` takes `self` and points at the file. Flakes copy the repo into the Nix
store, so the path resolves at build time.

Link into the home directory (see `modules/core/editor/cursor.nix`):

```nix
home.file.".config/Cursor/User/settings.json".source =
  fmt.generate "cursor-settings.json" (lib.importJSON "${self}/config/cursor/settings.json");
```

Read at evaluation time (JSON only):

```nix
lib.importJSON "${self}/config/command-code/settings.json"
```

Pass a path to a program:

```nix
command = "oh-my-posh claude --config ${self}/config/omp/claude.omp.json";
```

## Rules

- Use `"${self}/config/<tool>/<file>"`. Do not use relative paths such as `./config/...`.
- Run `git add` on new files before building. Flakes only see files tracked by git, and an
  untracked file fails with a missing-path error.
- No secrets. Encrypted values go in `secrets/` (sops-nix).
- Files are read-only in the Nix store. A tool that rewrites its own config will fail or need an
  out-of-store symlink. Check how the existing module handles that tool before copying its pattern.
