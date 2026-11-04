#!/usr/bin/env -S fish --no-config
nix run .#write-flake
or exit 1
alejandra flake.nix
set inputs (nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]' | sort)
or exit 1
set pick (string join \n $inputs | fzf --multi --cycle --layout=reverse-list --border rounded --height 80% \
    --header 'pick inputs to update — tab multi-select' \
    --query="$argv")
or exit 0
test -n "$pick"
or exit 0
nix flake update $pick
