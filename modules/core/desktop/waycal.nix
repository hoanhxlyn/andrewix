{self, ...}: {
  core.desktop.waycal.homeManager = {
    pkgs,
    config,
    ...
  }: let
    inherit (config.lib.stylix) colors;
    inherit (config.stylix) fonts;
  in {
    home.packages = [
      (pkgs.callPackage "${self}/packages/waycal" {})
    ];

    # Theme waycal from the active stylix scheme. Regenerated on every rebuild,
    # so changing the base16 scheme or fonts in stylix.nix re-themes waycal too.
    # Colors go through @define-color (referenced by the layout in main.rs); the
    # font family/size rule overrides the built-in fallback because this file is
    # concatenated AFTER the layout (see load_css in main.rs). waycal is a popup,
    # so it tracks stylix's `popups` size and the monospace family.
    xdg.configFile."waycal/style.css".text = ''
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
}
