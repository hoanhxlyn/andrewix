{self, ...}: {
  core.desktop.login.regreet = {host, ...}: {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }:
      lib.mkIf (host.login == "regreet") (let
        blurredBackground = import "${self}/modules/_lib/blurred-image.nix" {
          inherit pkgs;
          image = config.stylix.image;
        };
      in {
        programs.regreet = {
          enable = true;
          # Blur the stylix wallpaper (stylix sets the unblurred image by default).
          settings.background.path = lib.mkForce "${blurredBackground}";
        };

        systemd.services.greetd.environment.XCURSOR_SIZE =
          lib.mkIf (!(host.isLaptop or false))
          (toString config.stylix.cursor.size);
      });
  };
}
