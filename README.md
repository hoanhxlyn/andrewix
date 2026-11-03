# Andrewix

Visual overview of this config: **[andrewix.pages.dev](https://andrewix.pages.dev)**

Personal NixOS and Home Manager configuration for six hosts: four physical machines
(`asus-vivo14`, `asus-rog-gl552vx`, `msi-gf63`, `home-pc`) and two WSL installs
(`home-wsl`, `work-wsl`). It is built with flake-parts and the
[den](https://github.com/denful/den) dendritic framework.

## Guide

Day to day, run these from the repo root. The host defaults to `hostname -s`.

```bash
just build <host>         # Build only, catches eval errors
just switch <host>        # Apply the config
just test <host>          # Validate the running system (needs sudo)
just update               # Update flake inputs, no commit
just iso                  # Build the custom installer ISO
just fmt && just lint     # Format and lint
```

Without `just`: `nix run .#<host> -- build|switch|test`.

### Fresh install

Installable hosts come from the flake (every host with a disk layout, so not WSL); the installer
lists them and asks which one. Disks are partitioned declaratively with
[disko](https://github.com/nix-community/disko), so there is nothing to partition by hand.

1. Download the custom installer ISO
   ([Google Drive](https://drive.google.com/file/d/168gGL8QO5dx9J8F61At7qkWiaLxMorWf/view?usp=sharing))
   or build it with `just iso`, then write it to a USB stick.

1. Boot it and connect to the network (`nmtui`).

1. Run `andrewix-install`. It asks which host to install, which disk to use for each role, the
   login password and the passphrase for the shared age key.

1. Reboot and log in as `andrew` with the password you set. The installer already put the age key
   in `~/.config/sops-nix/keys.txt`, so sops decrypts the secrets on first boot.

**NOTE:** Only needed if the age key step was skipped or failed. Clone the repo on the installed
system, place the key and reboot:

```bash
git clone https://github.com/hoanhxlyn/andrewix ~/andrewix
mkdir -p ~/.config/sops-nix
age -d ~/andrewix/secrets/keys.age > ~/.config/sops-nix/keys.txt
chmod 600 ~/.config/sops-nix/keys.txt
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
