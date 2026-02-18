# Task Completion Checklist - Andrewix

## Before Committing Changes

### 1. Format Code
```bash
alejandra .
```
- Ensures consistent formatting across all Nix files
- Enforced by pre-commit hooks

### 2. Lint for Best Practices
```bash
statix check
```
- Checks for Nix anti-patterns
- Suggests improvements

### 3. Check for Unused Code
```bash
deadnix --no-underscore --fail
```
- Detects unused bindings and variables
- Fails if any found (useful for CI)

### 4. Validate Flake
```bash
nix flake check
```
- Critical safety check
- Validates all NixOS configurations
- Checks for evaluation errors
- **ALWAYS run before committing structural changes**

### 5. Run Pre-commit Hooks
```bash
pre-commit run --all-files
```
- Runs all quality checks in sequence
- Includes: alejandra, statix, deadnix

## After Changes

### System Rebuild (if modifying system config)
```bash
nh os switch ~/dotconfigs
```

### Regenerate Flake (if modifying flake inputs)
```bash
nix run .#write-flake
```

## Critical Safety Rules
- State Version is `25.11` - **Do not change** without manual migration
- flake.nix is auto-generated - **Do not edit directly**
- Always run `nix flake check` before structural changes
- Never commit secrets or API keys
- Never skip pre-commit hooks for important changes

## Testing Commands
```bash
# Test specific host build
nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel

# Test syntax of a specific file
nix-instantiate --eval /path/to/file.nix
```
