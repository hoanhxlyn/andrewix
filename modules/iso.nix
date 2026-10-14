{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({
        modulesPath,
        pkgs,
        ...
      }: {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          (import "${self}/modules/core/editor/_nwm/wrapper.nix" {inherit inputs self;})
        ];
        environment.systemPackages = with pkgs; [
          gum
          fish
          ripgrep
          fd
          fzf
          eza
          bat
          zoxide
          # The repo is baked into the ISO (isoImage.contents below), so the
          # installer is one word: no URL to type, nothing to clone.
          (writeShellApplication {
            name = "andrewix-install";
            text = "exec /iso/andrewix/install.fish";
          })
        ];
        # Serial console (systemd auto-spawns serial-getty@ttyS0 from this) so
        # the installer is usable headless / in a VM. mkAfter keeps root=fstab.
        boot.kernelParams = pkgs.lib.mkAfter ["console=ttyS0,115200n8"];
        # Fetching the flake's many `github:` inputs in parallel exhausts the
        # live session's 1024 fd soft limit ("too many open files"), breaking
        # both install.fish's `nix eval` and nixos-install.
        security.pam.loginLimits = [
          {
            domain = "*";
            type = "-";
            item = "nofile";
            value = "1048576";
          }
        ];
        nix.settings.experimental-features = ["nix-command" "flakes"];
        isoImage.edition = "andrewix";
        # Read-only copy of this flake at /iso/andrewix on the live ISO.
        isoImage.contents = [
          {
            source = self.outPath;
            target = "andrewix";
          }
        ];
      })
    ];
  };
}
