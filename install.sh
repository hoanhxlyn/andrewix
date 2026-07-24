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

HOST=$(gum choose "andrew-laptop" "andrew-pc")

gum confirm --default=false \
  "Install ${HOST}?" || exit 0

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

echo -e "\n${YELLOW}Select target disk (WILL BE ERASED):${NC}"
DISK=$(lsblk -dpno NAME,SIZE,MODEL | gum choose | awk '{print $1}')

gum confirm --default=false \
  "ERASE ${DISK} and install ${HOST}?" || exit 0

echo -e "\n${YELLOW}Partitioning + installing NixOS...${NC}"
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest#disko-install -- \
  --flake "$CLONE_DIR#$HOST" --disk main "$DISK"

echo -e "\n${GREEN}Done. Reboot.${NC}"
