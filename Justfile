host := `hostname -s`

l:
    just --list

fmt:
    alejandra .

lint:
    statix check
    deadnix --no-underscore --fail

check:
    nix flake check .

build h=host *args:
    nix run .#{{ h }} -- build {{ args }}

test h=host *args:
    nix run .#{{ h }} -- test {{ args }}

switch h=host *args:
    nix run .#{{ h }} -- switch {{ args }}

update:
    nix flake update --commit-lock-file

gc:
    nix store gc --debug

clean-up:
    nix-collect-garbage  --delete-old
