#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Andrewix NixOS Installer ===${NC}"

if [ "$(id -u)" -eq 0 ]; then
  echo -e "${RED}ERROR: Do not run as root${NC}"
  exit 1
fi

mapfile -t DISKS < <(
  lsblk -d -n -o NAME,SIZE,TYPE,TRAN 2>/dev/null \
    | grep disk \
    | grep -v usb \
    | awk '{print "/dev/" $1 " (" $2 ")"}'
)

if [ ${#DISKS[@]} -eq 0 ]; then
  echo -e "${RED}No suitable disks found${NC}"
  exit 1
fi

if [ ${#DISKS[@]} -eq 1 ]; then
  DISK_NAME=$(echo "${DISKS[0]}" | awk '{print $1}')
  echo -e "${GREEN}Single disk: $DISK_NAME${NC}"
else
  echo "Select disk:"
  DISK_NAME=$(printf '%s\n' "${DISKS[@]}" | gum choose | awk '{print $1}')
fi

RAM_GB=$(awk '/MemTotal/{printf "%.0f", $2/1024/1024}' /proc/meminfo)
DEFAULT_SWAP="$((RAM_GB + 1))G"
SWAP=$(gum input --placeholder "Swap size" --value "$DEFAULT_SWAP")

HOST=$(gum choose "andrew-laptop" "andrew-pc")

gum confirm --default=false \
  "WIPE ${DISK_NAME} entirely and install ${HOST}?" || exit 0

REPO_URL="https://github.com/hoanhxlyn/andrewix.git"
CLONE_DIR="$HOME/andrewix"

for i in $(seq 1 30); do
  if ping -c 1 github.com &>/dev/null; then
    break
  fi
  echo "Waiting for network..."
  sleep 2
done

if [ -d "$CLONE_DIR/.git" ]; then
  echo "Repo exists, updating..."
  git -C "$CLONE_DIR" pull --ff-only
else
  git clone "$REPO_URL" "$CLONE_DIR"
fi

echo -e "\n${YELLOW}Partitioning disk...${NC}"
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode zap_create_mount \
  --argstr device "$DISK_NAME" \
  --argstr swapSize "$SWAP" \
  "$CLONE_DIR/disko/$HOST/_nixos/default.nix"

echo -e "\n${YELLOW}Installing NixOS...${NC}"
sudo nixos-install --flake "$CLONE_DIR#$HOST" --no-root-password

echo -e "\n${GREEN}Done. Reboot.${NC}"
