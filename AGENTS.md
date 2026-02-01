# AGENTS.md - NixOS Dotfiles Configuration

This repository contains Andrew's NixOS and home-manager dotfiles configuration using the [nvf](https://github.com/NotAShelf/nvf) Neovim flake and home-manager.

## Build Commands

### System Updates
```bash
# Update flake inputs (run from ~/dotconfigs)
nix flake update --flake ~/dotconfigs

# Switch NixOS configuration
nh os switch ~/dotconfigs

# Clean all nix garbage
nh clean all

# Optimise nix store
nix store optimise
```

### Development Shell
```bash
# Enter development shell (defined in flake.nix devShells)
nix develop

# Or use the default shell directly
```

### Flake Commands
```bash
# Show flake outputs
nix flake show

# Lock flake inputs
nix flake lock

# Check flake for errors
nix flake check
```

## Code Style Guidelines

### Nix Formatting
- Use **nixfmt** for all `.nix` files (configured as default formatter in neovim)
- Indentation: 2 spaces
- Attribute sets: prefer concise form when attributes fit on one line
- Let-bindings: use `let ... in` pattern with proper spacing

### Nix Conventions
- Always use `{ pkgs, ... }@inputs` pattern for module inputs
- Import modules using `./relative/path.nix` syntax
- Use `inherit` for passing arguments to reduce repetition
- Keep configuration options organized by subsystem (programs, services, etc.)
- Use `pkgs.lib.nixosSystem` for NixOS module definitions

### Module Structure
- NixOS modules: `nixos/*.nix` - system-level configuration
- Home-manager modules: `modules/*.nix` - user-level configuration
- Each module should be self-contained with clear imports
- Use descriptive variable names (`hostName`, `username`, `stateVersion`)

### Neovim Configuration (nvf)
- Use `programs.nvf.settings` for Neovim configuration
- Follow the nested structure: `vim.*`, `vim.languages.*`, `vim.mini.*`
- Keymaps: use `vim.keymaps` array with mode, action, and desc fields
- Use Lua for complex configurations via `__raw` attribute

### Lua Files
- Store in `utils/` directory
- Follow Lua conventions: lowercase with underscores for variables
- Use `require()` for module imports

### JSON Files
- Configuration files like `andrew.omp.json` should be properly formatted
- Use consistent indentation (2 spaces)

## Error Handling

### Nix Module Errors
- Use `lib.asserts` for configuration validation
- Check for `enable = true` before setting related options
- Use `mkIf` or `mkDefault` for conditional configuration

### Home Manager
- Ensure proper imports to avoid "unknown option" errors
- Follow module structure: `{ config, pkgs, ... }@inputs: { ... }`

## Import Patterns

```nix
# Standard module import pattern
{ config, pkgs, ... }@inputs:
{
  imports = [
    ./relative/module.nix
  ];

  programs.example = {
    enable = true;
    settings = {
      # configuration here
    };
  };
}
```

## Naming Conventions

- **Variables**: `camelCase` (e.g., `hostName`, `stateVersion`)
- **Modules**: `kebab-case.nix` (e.g., `shell.nix`, `git.nix`)
- **Functions**: `camelCase` or `snake_case` depending on context
- **Booleans**: `enable`, `disable` pattern (e.g., `enable = true`)

## Key Configuration Patterns

### NixOS Configuration
```nix
{
  imports = [
    ./hardware-configuration.nix
    ./programs.nix
    # ... other modules
  ];
  boot.loader.systemd-boot.enable = true;
  networking.hostName = hostName;
  system.stateVersion = stateVersion;
}
```

### Home Manager Modules
```nix
{ pkgs, ... }@inputs:
{
  home = {
    inherit username stateVersion;
    homeDirectory = "/home/${username}";
  };
  programs.example.enable = true;
}
```

## Formatting Tools

- **Nix**: `nixfmt` (run via conform-nvim or CLI: `nixfmt file.nix`)
- **TypeScript/JavaScript**: `biome` (configured in neovim)
- **Lua**: Built-in Lua formatter or `lua-format`

## Repository Structure

```
~/dotconfigs/
├── flake.nix              # Main flake definition
├── home.nix               # Home-manager entry point
├── nixos/                 # NixOS system modules
│   ├── configuration.nix  # Main system config
│   ├── neovim.nix         # Neovim/Nvf config
│   ├── programs.nix       # System programs
│   └── ...
├── modules/               # Home-manager modules
│   ├── shell.nix          # Fish shell config
│   ├── git.nix            # Git config
│   └── ...
├── utils/                 # Lua utilities
└── andrew.omp.json        # Oh My Posh theme
```

## Important Notes

- State version: `25.11` - do not change unless migrating
- Hostname: `andrewix` - used in flake.nix nixosConfigurations
- Username: `andrew` - used throughout configuration
- Font family: `CaskaydiaCove Nerd Font` - used in GTK and terminal
- The flake uses `nixd` for Nix LSP and `nixfmt` for formatting
- MCP servers (serena, context7, tavily) are configured in `modules/agents.nix`
