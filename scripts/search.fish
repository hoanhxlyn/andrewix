#!/usr/bin/env -S fish --no-config
# nps -f flips its output so best matches sit at top; --with-nth=1/--nth=1 keep
# fzf to the name column. Preview shows version, rule, description. Enter copies name.
nps -e -f $argv | fzf --cycle --layout=reverse-list --border rounded --height 80% \
    --preview-window right:40%:wrap \
    --with-nth=1 --nth=1 \
    --preview "printf '%s\n%s\n%s\n' {2} '──────────────────────' {3..} | bat -p --color=always" \
    --bind 'enter:become(echo -n {1} | wl-copy)'
