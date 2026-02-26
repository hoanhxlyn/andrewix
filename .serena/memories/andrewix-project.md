# Project: andrewix

This is a NixOS + Home Manager dotfiles configuration with dendritic (aspect-first) architecture using flake-parts.

## Key Info
- Username: andrew
- System: x86_64-linux
- State Version: 25.11

## Hosts
- andrew-pc: Desktop configuration
- andrew-laptop: Laptop configuration

 Commands
-## Essential `nh os test .` - Validate config before commit
- `nh os switch .` - Apply config (requires sudo)
- `alejandra .` - Format Nix files
- `statix check` - Lint for best practices
- `nix flake check` - Check for evaluation errors
- `nix flake update --flake .` - Update all flake inputs

## Code Style
- Formatter: alejandra (2 spaces, no tabs)
- Files: kebab-case.nix
- Variables: camelCase
- Booleans: enable/disable prefix
- Use `lib.mkDefault` for overridable values
- Use `with pkgs;` for package lists

## Architecture
- flake.nix is auto-generated (DO NOT EDIT)
- Modules in modules/core/ (NixOS) and modules/andrew/ (Home Manager)
- Use `includes = [ ... ]` for den aspect dependencies
- Use angle bracket syntax: `<den/...>`, `<my/...>`

## Research
- Always use context7 and websearch to research and confirm your knowledge

## No Unit Tests
Validation via `nh os test .` and `nix flake check` only.