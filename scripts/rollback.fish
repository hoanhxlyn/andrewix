#!/usr/bin/env -S fish --no-config
set gen (nixos-rebuild list-generations | tail -n +2 | fzf --header 'pick a generation to rollback to' | awk '{print $1}')
if test -z "$gen"
    printf 'no generation selected\n'
    exit 0
end
sudo nix-env --switch-generation $gen -p /nix/var/nix/profiles/system
or exit 1
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
