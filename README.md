# Andrewix — NixOS + Home Manager Config

Personal NixOS + Home Manager config using flake-parts with dendritic architecture.

## Quick Start

```bash
just switch <host>        # Apply config
just test <host>          # Validate (requires sudo)
just check                # Eval errors
just update               # Update flake inputs (commits lock)
just fmt && just lint     # Format + lint
```

Hosts: `andrew-laptop`, `andrew-pc`, `andrew-home-wsl`, `andrew-work-wsl`.
Default host auto-detected via `hostname -s`.

### No Justfile?

```bash
nix run .#<host> -- switch
nix run .#<host> -- test
nix flake check
nix flake update --flake .
alejandra . && statix check && deadnix --no-underscore --fail
```

## Architecture

| Path | Purpose |
|------|---------|
| `modules/core/` | System-level aspects → NixOS |
| `modules/my/` | User-level aspects → Home Manager |
| `modules/devices/` | Per-device aspects (laptop, wsl) |
| `modules/defaults.nix` | Default includes for all hosts |
| `modules/hosts.nix` | Host definitions |
| `modules/users/andrew.nix` | User identity + aspect composition |
| `hosts/<host>/_nixos/` | Hardware configs |
| `disko/<host>/` | Disk partitioning |
| `secrets/` | sops-nix encrypted secrets |
| `config/` | Non-Nix app configs |
| `flake.nix` | **Auto-generated. DO NOT EDIT.** |

Aspects auto-discovered. Compose via `den.aspects.<name>.includes` with angle-bracket imports (`<core/sound>`, `<my/shell>`).

## Garbage Collection

```bash
just gc        # User store
just clean-up  # System-wide + delete old gens (sudo)
```

## Secrets

Encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using a shared age key.

- **Encrypted file:** `secrets/secrets.yaml` (safe to commit)
- **Age key location:** `~/.config/sops-nix/keys.txt` on each host
- **Edit secrets:** `sops secrets/secrets.yaml`
- **Setup new host:** copy the shared age private key to `~/.config/sops-nix/keys.txt`

## More

See `AGENTS.md` for conventions, module patterns, and rules.
