# Migration to Den Framework

This document describes the migration of the Andrewix NixOS configuration to use the Den (Dendritic Nix) framework.

## What Changed

### Architecture

The configuration was restructured from a flake-parts-based setup to use Den's dendritic pattern:

**Before:**
- Host configurations in `modules/hosts/{host}/default.nix`
- System aspects in `modules/system/aspects/`
- User aspects in `modules/user/aspects/`
- Manual module imports via `modules/hosts.nix`

**After:**
- All aspects in `modules/aspects/andrewix/`
- Host definitions in `modules/aspects/my/hosts.nix` using `den.hosts`
- Automatic module discovery via `import-tree`
- Parametric aspects using `den.lib.parametric`

### New Files

1. **`modules/dendritic.nix`**: Den framework integration
2. **`modules/namespace.nix`**: Andrewix namespace definition
3. **`modules/inputs.nix`**: Centralized flake inputs
4. **`modules/devshell.nix`**: Development shell configuration
5. **`modules/aspects/`**: New aspect structure
   - `andrewix/common.nix`: Common aspect aggregator
   - `andrewix/system/`: System-level aspects
   - `andrewix/user/`: User-level aspects
   - `my/hosts.nix`: Host and home definitions
   - `my/state-version.nix`: State version configuration

### Changed Files

1. **`outputs.nix`**: Now uses `import-tree` for automatic module discovery
2. **`README.md`**: Updated with Den framework documentation
3. **All aspect files**: Updated to use `den.lib.parametric` pattern

### Obsolete Files (Can be removed)

The following files and directories are no longer used but are kept for reference:

- `modules/hosts/` - Replaced by aspects in `modules/aspects/andrewix/system/hardware/` and `modules/aspects/my/hosts.nix`
- `modules/system/` - Migrated to `modules/aspects/andrewix/system/`
- `modules/user/` - Migrated to `modules/aspects/andrewix/user/`
- `modules/hosts.nix` - Replaced by `modules/aspects/my/hosts.nix`

**To clean up:**
```bash
git rm -r modules/hosts modules/system modules/user modules/hosts.nix
git commit -m "Remove obsolete pre-Den configuration files"
```

## Migration Steps Performed

1. **Added Den Input**: Added `den.url = "github:vic/den"` to flake inputs
2. **Created Den Integration**: 
   - `dendritic.nix` imports Den's flake modules
   - `namespace.nix` creates the `andrewix` namespace
3. **Restructured Modules**:
   - Copied all aspects to `modules/aspects/andrewix/`
   - Created hardware aspects per host
   - Created hostname aspects per host
4. **Updated Aspect Pattern**:
   - Wrapped all aspects with `den.lib.parametric`
   - Removed old `config.aspects` option references
   - Updated to use `osConfig.aspects` with fallbacks where needed
5. **Converted Host Definitions**:
   - Created `den.hosts.x86_64-linux.{host}` for each host
   - Created `den.homes.x86_64-linux.{user}` for each user
   - Defined `den.aspects.{host}.includes` with aspect lists
6. **Added System Aspects**:
   - `unfree.nix`: Allow unfree packages
   - `overlays.nix`: Nixpkgs overlays (rust-overlay, fcitx5-vmk)
7. **Updated Outputs**: Changed to use `import-tree` for automatic discovery

## Benefits

1. **Modularity**: Aspects can be easily reused across hosts
2. **Parametric Configuration**: Aspects can accept parameters
3. **Automatic Discovery**: No manual imports needed for aspects
4. **Composability**: Easy to mix and match aspects per host
5. **Maintainability**: Clear separation of concerns
6. **Documentation**: Self-documenting aspect structure

## Usage Examples

### Adding a New Aspect

Create `modules/aspects/andrewix/system/my-aspect.nix`:

```nix
{den, ...}: {
  andrewix.system.my-aspect = den.lib.parametric {
    config = {
      # Your configuration here
    };
  };
}
```

Include in a host:

```nix
den.aspects.my-host.includes = [
  <andrewix/system/my-aspect>
];
```

### Creating a Parametric Aspect

```nix
{den, ...}: {
  andrewix.system.configurable = den.lib.parametric ({
    option1 ? "default",
    option2 ? true,
    ...
  }: {
    config = {
      # Use option1 and option2 here
    };
  });
}
```

Use with parameters:

```nix
den.aspects.my-host.includes = [
  (<andrewix/system/configurable> {
    option1 = "custom";
    option2 = false;
  })
];
```

## Testing

After migration, test each host configuration:

```bash
# Test andrew-pc
nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel

# Test andrew-laptop
nix build .#nixosConfigurations.andrew-laptop.config.system.build.toplevel

# Switch to new configuration
nh os switch .
```

## Rollback

If needed, you can rollback to the pre-migration state:

```bash
git checkout <commit-before-migration>
nh os switch .
```

The commit before migration is tagged as `pre-den-migration` for easy reference.

## References

- [Den Framework](https://github.com/vic/den)
- [Dendritic Pattern](https://dendrix.oeiuwq.com/)
- [import-tree](https://github.com/vic/import-tree)
- [Reference Implementation: fbsb/chaos](https://github.com/fbsb/chaos)
