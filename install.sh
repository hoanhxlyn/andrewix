#!/usr/bin/env bash
set -euo pipefail

# gum is not on the stock NixOS ISO; pull it into a nix shell only when missing
# (the custom `iso` already ships it). nix itself is always present.
if ! command -v gum >/dev/null; then
  exec nix --extra-experimental-features "nix-command flakes" \
    shell nixpkgs#gum -c bash "$0" "$@"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Andrewix NixOS Installer ===${NC}"

if [ "$(id -u)" -eq 0 ]; then
  echo -e "${RED}ERROR: Do not run as root${NC}"
  exit 1
fi

HOST=$(gum choose "andrew-laptop" "andrew-pc" || true)
[ -z "$HOST" ] && exit 0

gum confirm --default=false \
  "Install ${HOST}?" || exit 0

REPO_URL="https://github.com/hoanhxlyn/andrewix.git"
CLONE_DIR="$HOME/andrewix"

if [ -d "$CLONE_DIR/.git" ]; then
  echo "Repo exists, updating..."
  git -C "$CLONE_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$CLONE_DIR"
fi

# Disk roles come from the flake (source of truth), not from the host name, so
# laptop=1 disk and pc=3 disks need no special-casing here. diskOrder sets the
# prompt order; an empty list falls back to alphabetical attrNames.
DISKS=$(nix eval --raw --extra-experimental-features "nix-command flakes" \
  "$CLONE_DIR#nixosConfigurations.$HOST" \
  --apply 'c: let
    order = c.config.core.hardware.disko.diskOrder;
  in builtins.concatStringsSep "\n" (
    if order == []
    then builtins.attrNames c.config.disko.devices.disk
    else order
  )')

echo -e "\n${YELLOW}Pick a target disk for each role (chosen disks WILL BE ERASED):${NC}"
# The disk we're booted from: disko can't unmount/erase a live root, and
# sgdisk --zap-all on it would destroy the running system. (On the ISO, / is an
# overlay with no parent disk, so this stays empty and the guard is a no-op.)
root_disk=""
root_src=$(findmnt -no SOURCE / 2>/dev/null || true)
if [[ "$root_src" == /dev/* ]]; then
  root_disk="/dev/$(lsblk -ndo PKNAME "$root_src" 2>/dev/null | head -n1)"
fi
args=()
while IFS= read -r name; do
  [ -z "$name" ] && continue
  # TYPE=="disk" drops the live ISO's own loop devices (and CD-ROMs, which also
  # pass the RM test); RM==0 drops removable media, i.e. the live installer USB.
  dev=$(lsblk -dpno NAME,SIZE,MODEL,RM,TYPE | awk '$NF == "disk" && $(NF-1) == 0' \
    | gum choose --header "disk '${name}'" | awk '{print $1}' || true)
  [ -z "$dev" ] && exit 0
  if [ -n "$root_disk" ] && [ "$dev" = "$root_disk" ]; then
    echo -e "${RED}ERROR: $dev is the disk you are running from.${NC}"
    echo "Boot the installer ISO and run ./install from there."
    exit 1
  fi
  args+=("$name=$dev")
  echo -e "  ${GREEN}${name}${NC} -> ${dev}"
done <<<"$DISKS"

gum confirm --default=false \
  "ERASE the selected disks and install ${HOST}? ALL DATA ON THEM IS LOST." || exit 0

echo -e "\n${YELLOW}Partitioning the selected disks...${NC}"
# Do this in two steps rather than with disko-install: disko-install builds the
# system in the live store, which on the ISO is a tmpfs capped at 50% of RAM —
# too small for this closure on most machines. disko just formats + mounts,
# then nixos-install builds straight into the target store (no RAM ceiling).
# disko has no --disk, so hand it a config with each role's device filled in.
DISKO_CONFIG=$(mktemp /tmp/andrewix-disko-XXXX.nix)
{
  printf '{lib, ...}:\nlet\n'
  printf '  f = builtins.getFlake "%s";\n' "$CLONE_DIR"
  printf '  d = f.nixosConfigurations.%s.config.disko.devices.disk;\n' "$HOST"
  printf '  dev = {'
  for pair in "${args[@]}"; do
    printf ' %s = "%s";' "${pair%%=*}" "${pair#*=}"
  done
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
} >"$DISKO_CONFIG"

# NIX_CONFIG so the disko script's own nix-build (which evaluates the config
# above, using builtins.getFlake) also has flakes enabled — the stock ISO has
# them off, and --extra-experimental-features on `nix run` doesn't cross into it.
sudo NIX_CONFIG="experimental-features = nix-command flakes" \
  nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest#disko -- \
  --mode destroy,format,mount --yes-wipe-all-disks "$DISKO_CONFIG"

echo -e "\n${YELLOW}Installing NixOS (builds into the target disk, not RAM)...${NC}"
# fallback: if a substitute is missing/fails (e.g. a path newer than any cache),
# build it from source instead of aborting the whole install.
sudo NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-install --flake "$CLONE_DIR#$HOST" --no-root-passwd --option fallback true

echo -e "\n${GREEN}Done. Default login password is admin123 — change it with 'passwd' after first boot. Reboot.${NC}"
