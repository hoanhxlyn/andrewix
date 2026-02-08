# Andrewix - NixOS & Home Manager Configuration

This repository contains Andrew's NixOS and Home Manager configuration using flake-parts with automatic module discovery.

## 🚀 Quick Start

*   **Apply latest configuration:**
    ```bash
    nh os switch ~/dotconfigs
    ```
*   **Update all inputs:**
    ```bash
    nix flake update --flake ~/dotconfigs
    ```
*   **Check for evaluation errors:**
    ```bash
    nix flake check
    ```

## 🛠 Architecture

This configuration follows a dendritic (tree-like) structure with category-based organization.

-   `modules/system/aspects/`: System-level NixOS modules (auto-imported).
-   `modules/user/aspects/`: User-level Home Manager modules (auto-imported).
-   `modules/hosts/`: Hardware-specific configurations for different machines.
-   `flake.nix`: The main flake entry point, auto-generated from the modules.
-   `outputs.nix`: The main flake configuration using flake-parts.

We use `vic/import-tree` for automatic module discovery. Any `.nix` file in the `aspects/` directories is automatically imported and integrated into the build.

## 📝 Development Workflow

### 1. Modify Existing Configuration

To modify the configuration, edit the appropriate `.nix` files in `modules/system/aspects/` for system-wide changes, or `modules/user/aspects/` for user-specific settings.

### 2. Add New Features

To add a new feature, create a new `.nix` file in the relevant `aspects/` subdirectory. For example, to add a new development tool, you might create `modules/user/aspects/development/new-tool.nix`.

### 3. Quality Assurance

Before committing any changes, please run the following commands to ensure code quality and consistency:

```bash
# Format all Nix files
alejandra .

# Lint for Nix best practices
statix check

# Check for evaluation errors
nix flake check

# Run all pre-commit hooks
pre-commit run --all-files
```

For more detailed information on commands, conventions, and architecture, please refer to the `AGENTS.md` file.
