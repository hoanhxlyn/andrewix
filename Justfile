host := `hostname -s`

# List all recipes
[group('info')]
l:
  just --list

# Format with alejandra
[group('validate')]
fmt:
  alejandra .

# Statix + deadnix check
[group('validate')]
lint:
  statix check
  deadnix --no-underscore --fail

# Build system config
[group('nixos')]
build h=host *args:
  nix run .#{{ h }} -- build {{ args }}  

# Boot new build at next restart
[group('nixos')]
boot h=host *args:
  nix run .#{{ h }} -- boot {{ args }}  

# Test system config
[group('nixos')]
test h=host *args:
  nix run .#{{ h }} -- test {{ args }}  

# Switch to system config
[group('nixos')]
switch h=host *args:
  nix run .#{{ h }} -- switch {{ args }}  

# Build + run test VM (host store mounted, disk untouched)
[group('nixos')]
vm h=host *args:
  nix run .#{{ h }} -- build-vm -r {{ args }}

# Update flake inputs
[group('nixos')]
update:
  nix run .#write-flake
  alejandra flake.nix
  nix flake update

# User store garbage collection
[group('nixos')]
gc:
  nix store gc
  nix store optimise

# Clean old kernel files from /boot (backs up current first)
[group('nixos')]
boot-clean:
  #!/usr/bin/env bash
  set -euo pipefail
  if [ ! -d /boot/kernels ]; then exit 0; fi
  current=$(readlink /run/current-system/kernel | grep -oP 'linux-\K[0-9.]+')
  [ -n "$current" ] || { echo "Failed to detect current kernel"; exit 1; }
  echo "Current kernel: $current"
  backup_dir=/var/backups/nixos-kernels
  sudo rm -rf "$backup_dir"
  sudo mkdir -p "$backup_dir"
  sudo find /boot/kernels/ -maxdepth 1 -type f -name "*$current*" -exec cp -t "$backup_dir" {} +
  sudo find /boot/kernels/ -maxdepth 1 -type f ! -name "*$current*" -delete
  # GRUB only — systemd-boot manages its own entries
  if [ -d /boot/grub ]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi

# System-wide GC, delete old gens (user profile + system, keep 7d)
[group('nixos')]
clean-up:
  nix profile wipe-history --older-than 7d
  nix-collect-garbage -d --delete-older-than 7d
  just boot-clean
  nix store optimise

# Search nix packages
[group('info')]
search *args:
  nps -e {{ args }} | fzf --cycle --layout=reverse-list --border rounded --height 80% --preview-window right:40%:wrap --bind 'enter:become(echo -n {1} | wl-copy)'

# List system generations
[group('nixos')]
list-gen:
  nixos-rebuild list-generations
