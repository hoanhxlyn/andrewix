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

echo -e "\n${YELLOW}Installing NixOS...${NC}"
sudo nixos-install --flake "$CLONE_DIR#$HOST" --no-root-password

echo -e "\n${GREEN}Done. Reboot.${NC}"
