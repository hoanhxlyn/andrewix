#!/usr/bin/env -S fish --no-config
set out (nix build --print-out-paths nixpkgs#base16-schemes)
or exit 1
set dir $out/share/themes
set pick (path basename $dir/*.yaml | fzf --cycle --layout=reverse-list --border rounded --height 80% \
    --header 'pick a scheme → copied on enter' \
    --query="$argv" \
    --preview "head -40 '$dir/{}'")
or exit 0
set name (string replace -r '\.yaml$' '' -- $pick)
printf %s $name | wl-copy
printf 'copied: %s\n' $name
