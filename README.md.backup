# Andrewix - Dendritic NixOS Configuration

A modular NixOS configuration using the [Den (Dendritic Nix)](https://github.com/vic/den) framework for composable system and user aspects.

## 🏗️ Architecture

This configuration uses Den's **dendritic pattern** for organizing reusable configuration aspects:

- **System aspects** (`modules/aspects/andrewix/system/`): Core system configuration, desktop environments, hardware, gaming, etc.
- **User aspects** (`modules/aspects/andrewix/user/`): User-level configuration for development tools, desktop apps, utilities
- **Host definitions** (`modules/aspects/my/hosts.nix`): Per-host configuration using `den.hosts` and `den.aspects`

### Key Features

- ✨ **Aspect-based architecture**: Reusable configuration modules using Den's parametric aspects
- 🎯 **Automatic module discovery**: Uses `import-tree` for zero-config module loading
- 🔧 **Host-specific customization**: Easy per-machine configuration via includes
- 👤 **User management**: Integrated home-manager via Den
- 🎨 **Theming**: Unified styling with Stylix

## 📁 Structure

```
andrewix/
├── flake.nix              # Auto-generated from flake-file
├── outputs.nix            # Main flake outputs using import-tree
├── modules/
│   ├── dendritic.nix      # Den framework integration
│   ├── namespace.nix      # Andrewix namespace definition
│   ├── inputs.nix         # Flake inputs configuration
│   ├── devshell.nix       # Development shell
│   └── aspects/
│       ├── andrewix/      # Shared aspects (public)
│       │   ├── common.nix
│       │   ├── system/    # System-level aspects
│       │   └── user/      # User-level aspects
│       └── my/            # Private aspects
│           ├── hosts.nix  # Host and home definitions
│           └── state-version.nix
```

## 🚀 Quick Start

### Building

```bash
# Test configuration (validate without switching)
nh os test .

# Build specific host
nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel
nix build .#nixosConfigurations.andrew-laptop.config.system.build.toplevel

# Apply configuration
nh os switch .
```

### Development

```bash
# Enter development shell
nix develop

# Format code
alejandra .

# Lint
statix check && deadnix --fail

# Update inputs
nix flake update

# Regenerate flake.nix
nix run .#write-flake
```

## 🖥️ Hosts

### andrew-pc (Desktop)
- NVIDIA GPU support
- Xbox One controller driver (xone)
- Steam gaming platform
- Alacritty terminal

### andrew-laptop
- Wezterm terminal
- Mobile-optimized power management

## 🎨 Aspects

### System Aspects

- **core**: Boot, fonts, i18n, programs, stylix theming
- **desktop**: GNOME, communication apps
- **gpu**: NVIDIA driver support
- **gaming**: Steam, xone controller driver
- **utilities**: Power management, TLP
- **terminal**: Terminal emulator configuration (parametric)
- **hardware**: Host-specific hardware configuration
- **hostname**: Host-specific hostname and device settings

### User Aspects

- **development**: Git, Neovim, development tools
- **desktop**: Browsers, Yazi, terminal emulators
- **utilities**: KeePassXC, rclone, shell configuration

## 📝 Adding a New Host

1. Update `modules/aspects/my/hosts.nix`:

```nix
den.hosts.x86_64-linux.new-host = {
  users = { /* ... */ };
  specialModules = [ /* ... */ ];
};

den.aspects.new-host.includes = [
  <andrewix/common>
  <andrewix/system/hardware/new-host>
  <andrewix/system/hostname/new-host>
  # Add other aspects...
];
```

2. Create hardware configuration at `modules/aspects/andrewix/system/hardware/new-host.nix`
3. Create hostname configuration at `modules/aspects/andrewix/system/hostname/new-host.nix`
4. Build and test: `nix build .#nixosConfigurations.new-host.config.system.build.toplevel`

## 🔧 Creating Custom Aspects

Aspects are parametric modules that can be reused across hosts:

```nix
{den, ...}: {
  andrewix.my-aspect = den.lib.parametric {
    imports = [ /* ... */ ];
    config = { /* ... */ };
  };
}
```

Use angle bracket syntax to include aspects:

```nix
den.aspects.my-host.includes = [
  <andrewix/my-aspect>
  (<andrewix/parametric-aspect> { param = value; })
];
```

## 📚 Resources

- [Den Framework](https://github.com/vic/den)
- [Dendritic Pattern](https://dendrix.oeiuwq.com/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager](https://github.com/nix-community/home-manager)

## 📄 License

MIT License - see LICENSE file for details.
