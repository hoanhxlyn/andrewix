### System Management
`nh os switch ~/dotconfigs` - Apply changes and switch to new configuration
`nh os build ~/dotconfigs` - Build configuration without switching (dry run)
`nix flake update --flake ~/dotconfigs` - Update all flake inputs
`nix flake check` - Check flake for evaluation errors (run before commits)
`nix run .#write-flake` - Regenerate flake.nix from modules
`nix build .#nixosConfigurations.andrew-pc.config.system.build.toplevel` - Test specific host configuration
`nh clean all` - Cleanup nix garbage and old generations
`nix store optimise` - Optimize nix store (deduplicate files)

### Code Quality & Formatting
`alejandra .` - Format all Nix files
`statix check` - Lint for Nix best practices
`deadnix --fail` - Find unused bindings
`pre-commit run --all-files` - Run all pre-commit hooks manually
`nix develop` - Enter development shell with all tools
`nix-instantiate --eval /path/to/file.nix` - Check specific file for syntax errors
