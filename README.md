# Andrewix - NixOS & Home Manager Configuration

## 🚀 Quick Start

Apply latest configuration:
```bash
nh os switch ~/dotconfigs
```

Update all inputs:
```bash
nix flake update --flake ~/dotconfigs
```

## 🛠 Architecture

- `modules/system/categories/`: System-level NixOS modules (auto-imported)
- `modules/user/categories/`: User-level Home Manager modules (auto-imported)  
- `modules/hosts/`: Hardware-specific configurations
- `flake.nix`: Auto-generated entry point (DO NOT EDIT)
- `outputs.nix`: Main flake configuration using flake-parts

## 📝 Development Workflow

### 1. Modify Existing Configuration
Edit files in `modules/system/categories/` (system) or `modules/user/categories/` (user).

### 2. Add New Features
Create `.nix` files in appropriate `categories/` directories. Example:
```nix
{ config, lib, ... }: {
  options.modules.desktop.vscode.enable = lib.mkEnableOption "vscode";
  
  config = lib.mkIf config.modules.desktop.vscode.enable {
    programs.vscode.enable = true;
  };
}
```

### 3. Quality Assurance
Always run before committing:
```bash
nix flake check    # Check for evaluation errors
alejandra .        # Format code
statix check       # Lint for best practices
pre-commit run --all-files  # Run all hooks
```
