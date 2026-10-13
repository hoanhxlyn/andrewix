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
# laptop=1 disk and pc=3 disks need no special-casing here.
DISKS=$(nix eval --raw --extra-experimental-features "nix-command flakes" \
  "$CLONE_DIR#nixosConfigurations.$HOST.config.disko.devices.disk" \
  --apply 'd: builtins.concatStringsSep "\n" (builtins.attrNames d)')

echo -e "\n${YELLOW}Pick a target disk for each role (chosen disks WILL BE ERASED):${NC}"
args=()
while IFS= read -r name; do
  [ -z "$name" ] && continue
  # RM==0 drops removable media, i.e. the live installer USB.
  dev=$(lsblk -dpno NAME,SIZE,MODEL,RM | awk '$NF == 0' \
    | gum choose --header "disk '${name}'" | awk '{print $1}' || true)
  [ -z "$dev" ] && exit 0
  args+=(--disk "$name" "$dev")
done <<<"$DISKS"

gum confirm --default=false \
  "ERASE the selected disks and install ${HOST}? ALL DATA ON THEM IS LOST." || exit 0

echo -e "\n${YELLOW}Partitioning + installing NixOS...${NC}"
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest#disko-install -- \
  --flake "$CLONE_DIR#$HOST" "${args[@]}"

echo -e "\n${GREEN}Done. Default login password is admin123 — change it with 'passwd' after first boot. Reboot.${NC}"
