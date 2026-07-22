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

# Update flake inputs
[group('nixos')]
update:
  nix run .#write-flake
  nix flake update

# User store garbage collection
[group('nixos')]
gc:
  nix store gc

# System-wide GC, delete old gens (user profile + system, keep 7d)
[group('nixos')]
clean-up:
  nix profile wipe-history --older-than 7d
  sudo nix-collect-garbage --delete-older-than 7d
  nix-collect-garbage -d --delete-older-than 7d

# Search nix packages
[group('info')]
search *args:
  nps -e {{ args }} | fzf --cycle --layout=reverse-list --border rounded --height 80% --preview-window right:40%:wrap --bind 'enter:become(echo -n {1} | wl-copy)'

# List system generations
[group('nixos')]
list-gen:
  nixos-rebuild list-generations
