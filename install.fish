#!/usr/bin/env fish
# @fish-lsp-disable 7001

if not command -s gum
    exec nix --extra-experimental-features "nix-command flakes" \
        shell nixpkgs#gum nixpkgs#fish -c fish (status filename) $argv
end

#===============
set -g accent 212
set -g danger 1
set -g warn 3
set -g success 10
set -g root_disk ""
set -g args
set confirm_default true

gum style --border rounded --border-foreground $accent --align center --width 60 \
    --padding "1 2" --margin "1 0" --bold --foreground $accent "Andrewix NixOS Installer"

if test (id -u) -eq 0
    gum style --foreground $danger --bold "ERROR: Do not run as root"
    exit 1
end

set HOST (gum choose andrew-laptop andrew-pc; or true)
if test -z "$HOST"
    exit 0
end

gum confirm --default=$confirm_default "Install $HOST?"; or exit 0

# ========== Clone/Fetch upstream ============
set REPO_URL "https://github.com/hoanhxlyn/andrewix.git"
set CLONE_DIR "$HOME/andrewix"
if test -f /iso/andrewix/flake.nix
    set CLONE_DIR /iso/andrewix
else if test -d "$CLONE_DIR/.git"
    gum style --italic "Repo exists, updating..."
    # --ff-only fails on a diverged history; abort (errexit had no fish
    # equivalent) rather than install a stale tree.
    git -C "$CLONE_DIR" pull --ff-only; or begin
        gum style --foreground $danger --bold "pull failed (diverged?). Remove $CLONE_DIR and re-run." >&2
        exit 1
    end
else
    git clone "$REPO_URL" "$CLONE_DIR"
end

# Disk roles come from the flake (source of truth), not from the host name, so
# laptop=1 disk and pc=3 disks need no special-casing here. diskOrder sets the
# prompt order; an empty list falls back to alphabetical attrNames.
set DISKS (nix eval --raw --extra-experimental-features "nix-command flakes" \
    "$CLONE_DIR#nixosConfigurations.$HOST" \
    --apply 'c: let
      order = c.config.core.hardware.disko.diskOrder;
    in builtins.concatStringsSep "\n" (
      if order == []
      then builtins.attrNames c.config.disko.devices.disk
      else order
    )')
if test (count $DISKS) -eq 0
    gum style --foreground $danger --bold "nix eval returned no disk roles for $HOST." >&2
    exit 1
end

gum style --foreground $warn --bold "Pick a target disk for each role (chosen disks WILL BE ERASED):"

# The disk we're booted from: disko can't unmount/erase a live root, and
# sgdisk --zap-all on it would destroy the running system. (On the ISO, / is an
# overlay with no parent disk, so this stays empty and the guard is a no-op.)
set root_src (findmnt -no SOURCE / 2>/dev/null; or true)
if string match -q '/dev/*' -- "$root_src"
    set -g root_disk "/dev/"(lsblk -ndo PKNAME "$root_src" 2>/dev/null | head -n1)
end

for name in $DISKS
    set dev (lsblk -dpno NAME,SIZE,MODEL,RM,TYPE | awk '$NF == "disk" && $(NF-1) == 0' \
        | gum choose --header "disk '$name'" | awk '{print $1}'; or true)
    if test -z "$dev"
        exit 0
    end
    if test -n "$root_disk"; and test "$dev" = "$root_disk"
        gum style --foreground $danger --bold "ERROR: $dev is the disk you are running from."
        gum style --italic "Boot the installer ISO and run ./install from there."
        exit 1
    end
    set -ga args "$name=$dev"
    gum style --foreground $accent "  $name -> $dev"
end

gum confirm --default=$confirm_default "ERASE the selected disks and install $HOST? ALL DATA ON THEM IS LOST."; or exit 0

# disko-install would build into the live store (tmpfs capped at 50% RAM — too
# small for this closure), so disko formats+mounts and nixos-install builds into
# the target. disko has no --disk flag, hence the config we generate below.
set DISKO_CONFIG (mktemp /tmp/andrewix-disko-XXXX.nix)

# fish has no `trap`; clean the temp config on the fish_exit event, which covers
# every exit path including early aborts.
function cleanup --on-event fish_exit
    rm -f "$DISKO_CONFIG"
end

begin
    printf '{lib, ...}:\nlet\n'
    printf '  f = builtins.getFlake "%s";\n' "$CLONE_DIR"
    printf '  d = f.nixosConfigurations.%s.config.disko.devices.disk;\n' "$HOST"
    printf '  dev = {'
    for pair in $args
        printf ' %s = "%s";' (string split -m1 = "$pair")
    end
    printf ' };\n'
    printf '%s\n' '  # The evaluated config has the placeholder device baked in everywhere'
    printf '%s\n' '  # (gpt content, partition filesystems). Drop every `device`; disko then'
    printf '%s\n' '  # re-derives them from the disk device we set below.'
    printf '%s\n' '  stripDev = x: if builtins.isAttrs x then builtins.mapAttrs (n: v: stripDev v) (lib.filterAttrs (n: _: n != "device") x) else x;'
    printf '%s\n' '  # drop module internals (_module, _pkgs) so it re-merges cleanly.'
    printf '%s\n' '  strip = x: if builtins.isAttrs x then builtins.mapAttrs (n: v: strip v) (lib.filterAttrs (n: _: !(lib.hasPrefix "_" n)) x) else x;'
    printf 'in {\n'
    printf '%s\n' '  disko.devices.disk = strip (builtins.mapAttrs (n: v: (stripDev v) // {device = dev.${n};}) d);'
    printf '}\n'
end >"$DISKO_CONFIG"

# ========= Partition part ============
gum spin --spinner dot --title "Partitioning the selected disks..." --show-error -- \
    sudo NIX_CONFIG="experimental-features = nix-command flakes" \
    nix --extra-experimental-features "nix-command flakes" \
    run github:nix-community/disko/latest#disko -- \
    --mode destroy,format,mount --yes-wipe-all-disks "$DISKO_CONFIG"; or exit $status

# ========= Installing part ============
gum spin --spinner dot --title "Installing NixOS" --show-output -- \
    sudo NIX_CONFIG="experimental-features = nix-command flakes" \
    nixos-install --flake "$CLONE_DIR#$HOST" --no-root-passwd --option fallback true; or exit $status

# =================
gum style --foreground $success --bold "Done. Default login password is admin123 - change it with 'passwd' after first boot. Reboot."
