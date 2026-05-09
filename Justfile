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

# Run nix flake check
[group('validate')]
check:
    nix flake check .

# Build system config
[group('nixos')]
build h=host *args:
    nix run .#{{ h }} -- build {{ args }}

# Test system config
[group('nixos')]
test h=host *args:
    nix run .#{{ h }} -- test {{ args }}

# Switch to system config
[group('nixos')]
switch h=host *args:
    nix run .#{{ h }} -- switch {{ args }}

# Update flake inputs
[group('nixos')]
update:
    nix run .#write-flake
    nix flake update

# User store garbage collection
[group('nixos')]
gc:
    nix store gc --debug

# System-wide GC, delete old gens
[group('nixos')]
clean-up:
    sudo nix-collect-garbage  --delete-old

# Search nix packages
[group('info')]
search *args:
    nps -e {{ args }}

# List system generations
[group('nixos')]
list-gen:
    nixos-rebuild list-generations
