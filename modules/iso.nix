# Custom installer ISO: stock minimal live CD + the repo's neovim wrapper and
# gum, so the install medium matches the environment we actually use.
# Build: `just iso` (or nix build .#nixosConfigurations.iso.config.system.build.isoImage).
{inputs, self, ...}: {
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({modulesPath, pkgs, ...}: {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          (import "${self}/modules/core/editor/_nwm/wrapper.nix" {inherit inputs self;})
        ];
        environment.systemPackages = [pkgs.gum];
        nix.settings.experimental-features = ["nix-command" "flakes"];
        isoImage.edition = "andrewix";
      })
    ];
  };
}
