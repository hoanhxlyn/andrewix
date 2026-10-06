#!/usr/bin/env fish

set -l cwd_file /tmp/yazi_last_cwd

if test -f "$cwd_file" -a -s "$cwd_file"
    set -l last_dir (cat "$cwd_file")
    if test -d "$last_dir"
        yazi --cwd-file="$cwd_file" "$last_dir"
    else
        yazi --cwd-file="$cwd_file"
    end
else
    yazi --cwd-file="$cwd_file"
end