#!/usr/bin/env -S fish --no-config
# SSH into the homelab once the tailnet reaches it (andrewix = asus-rog-gl552vx)
while not tailscale ping --c 1 --timeout 2s andrewix >/dev/null 2>&1
    echo 'andrewix unreachable on the tailnet, retrying...'
    sleep 2
end
ssh andrew@andrewix $argv
