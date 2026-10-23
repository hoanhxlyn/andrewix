# Andrewix

Visual overview of this config: **[andrewix.pages.dev](https://andrewix.pages.dev)**

Personal NixOS and Home Manager configuration for five hosts: three physical machines
(`asus-vivo14`, `asus-rog-gl552vx`, `home-pc`) and two WSL installs
(`home-wsl`, `work-wsl`). It is built with flake-parts and the
[den](https://github.com/denful/den) dendritic framework.

## Guide

Day to day, run these from the repo root. The host defaults to `hostname -s`.

```bash
just build <host>         # Build only, catches eval errors
just switch <host>        # Apply the config
just test <host>          # Validate the running system (needs sudo)
just update               # Update flake inputs, no commit
just fmt && just lint     # Format and lint
```

Without `just`: `nix run .#<host> -- build|switch|test`.

### Fresh install

Only the three physical hosts are installable. Disks are partitioned declaratively with
[disko](https://github.com/nix-community/disko), so there is nothing to partition by hand.

1. Boot the NixOS minimal ISO and connect to the network (`nmtui`).
1. Clone the repo and run the guided installer. It asks which disk to use for each role:

   ```bash
   git clone https://github.com/hoanhxlyn/andrewix ~/andrewix
   ~/andrewix/install.fish
   ```

1. Reboot and log in as `andrew` with the password the installer asked for. Secrets are already
   decrypted: the installer unpacks the shared age key (`secrets/keys.age`, passphrase-encrypted in
   the repo) into `~/.config/sops-nix/keys.txt` before the reboot. Skipped that step?

   ```bash
   age -d ~/andrewix/secrets/keys.age > ~/.config/sops-nix/keys.txt \
     && chmod 600 ~/.config/sops-nix/keys.txt
   ```

### Adding a device

Add one `mkHost` entry to `modules/hosts.nix` with its facts and monitors. Nothing else needs to
change.

## Documentation

| Where                                  | What                                                    |
| -------------------------------------- | ------------------------------------------------------- |
| [modules/README.md](modules/README.md) | How the config is structured, and how to add an aspect  |
| [config/README.md](config/README.md)   | Non-Nix app configs and how modules import them         |
| [AGENTS.md](AGENTS.md)                 | Conventions, host facts, secrets, GC and the hard rules |
