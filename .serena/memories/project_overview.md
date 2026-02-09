# Project Overview - Andrewix

## Purpose
Andrewix is a NixOS and Home Manager configuration repository using flake-parts with automatic module discovery. It manages system-wide and user-level configurations for Andrew's machines.

## Tech Stack
- **NixOS**: System configuration management
- **Home Manager**: User environment configuration
- **Flake-parts**: Modular flake composition
- **Auto-import**: Uses `vic/import-tree` for automatic module discovery
- **vic/flake-file**: Auto-generates flake.nix

## Key Flake Inputs
- nixpkgs (nixos-unstable)
- home-manager
- flake-parts
- import-tree
- flake-aspects
- rust-overlay
- aic8800 (for laptop WiFi)
- serena
- git-hooks-nix

## Hosts
- `andrew-pc`: Desktop configuration
- `andrew-laptop`: Laptop configuration (includes aic8800 module)

## Important Variables
- Username: `andrew`
- State Version: `25.11` (do not modify)
- Font Family: `CaskaydiaCove Nerd Font`
- System: `x86_64-linux`
