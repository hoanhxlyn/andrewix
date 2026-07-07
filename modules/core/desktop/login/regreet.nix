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
          settings.background.path = lib.mkForce "${blurredBackground}";
        };
      });
  };
}
