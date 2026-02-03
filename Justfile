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

# Build the custom installer ISO
[group('nixos')]
iso:
  nix build .#nixosConfigurations.iso.config.system.build.isoImage

# Update flake inputs
[group('nixos')]
update:
  nix run .#write-flake
  alejandra flake.nix
  nix flake update

# System-wide GC, delete old gens
[group('nixos')]
gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 3d
  nix profile wipe-history --older-than 3d
  sudo nix store gc -v

# List system generations
[group('nixos')]
list-gen:
  nix profile history --profile /nix/var/nix/profiles/system

# Rollback to a chosen generation via fzf
[group('nixos')]
rollback:
  fish --no-config scripts/rollback.fish

# Search nix packages
[group('info')]
search *args:
  fish --no-config scripts/search.fish {{ args }}

# Pick a base16 scheme with fzf, copy name on enter
[group('info')]
schemes:
  fish --no-config scripts/schemes.fish

