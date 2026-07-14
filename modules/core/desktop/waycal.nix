{inputs, ...}: {
  flake-file.inputs.waycalix.url = "github:hoanhxlyn/waycalix";

  core.desktop.waycal = {
    nixos.nix.settings = {
      extra-substituters = ["https://waycalix.cachix.org"];
      extra-trusted-public-keys = [
        "waycalix.cachix.org-1:nGZcdc7jmLn1cxr7t2mVOpZ+xpChExJWk9igdKX4yg0="
      ];
    };

    homeManager = {config, ...}: let
      inherit (config.lib.stylix) colors;
      inherit (config.stylix) fonts;
    in {
      imports = [inputs.waycalix.homeManagerModules.default];

      programs.waycal = {
        enable = true;
        css = ''
          @define-color waycal_bg #${colors.base00};
          @define-color waycal_fg #${colors.base05};
          @define-color waycal_dim #${colors.base03};
          @define-color waycal_accent #${colors.base0D};
          @define-color waycal_accent_fg #${colors.base00};

          .waycal-root {
            font-family: "${fonts.monospace.name}";
            font-size: ${toString fonts.sizes.popups}pt;
          }
        '';
      };
    };
  };
}
