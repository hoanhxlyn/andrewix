## What

## Why

## Checklist

- [ ] `just fmt && just lint` pass
- [ ] `just build <host>` (or `just test <host>`) passes
- [ ] `flake.nix` untouched (regenerated with `nix run .#write-flake` if inputs changed)
- [ ] `stateVersion` untouched
- [ ] No hostname mentioned outside `modules/hosts.nix`
- [ ] New aspect file is `git add`ed before building
