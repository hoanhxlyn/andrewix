{
  lib,
  inputs,
  self,
  ...
}: {
  flake-file.inputs.stylix = {
    # TODO: fork = master + stylix#2501 (rofi settings.font rename), revert when merged
    # README: https://github.com/nix-community/stylix/pull/2501
    url = "github:adomixaszvers/stylix/merged-rofi-settings-font";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.gruvbox-wallpapers = {
    url = "github:AngelJumbo/gruvbox-wallpapers";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.tokyonight-wallpapers = {
    url = "github:hoanhxlyn/tokyonight-wallpapers";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.walls-catppuccin-mocha = {
    # NOTE: fork of orangci/walls-catppuccin-mocha (upstream ships no flake.nix), sync from upstream
    url = "github:hoanhxlyn/walls-catppuccin-mocha";
  };
  core.services.sync.stylix = {host, ...}: let
    inherit (host) appearance;
  in {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];
      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${appearance.scheme}.yaml";
        inherit (appearance) polarity;
        cursor.package = pkgs.capitaine-cursors-themed;
        cursor.name = "Capitaine Cursors - White";
        cursor.size = host.accessibility.cursorSize;
        fonts = let
          # appearance.font.<role>.pkg is a pkgs attribute path; a bad path fails at eval.
          mkFont = f: {
            package = lib.getAttrFromPath (lib.splitString "." f.pkg) pkgs;
            inherit (f) name;
          };
        in {
          serif = config.stylix.fonts.sansSerif;
          sansSerif = mkFont appearance.font.sans;
          monospace = mkFont appearance.font.mono;
          emoji = mkFont appearance.font.emoji;
          sizes = {
            applications = appearance.font.size + 1;
            terminal = appearance.font.size;
            desktop = appearance.font.size + 2;
            popups = appearance.font.size;
          };
        };
        icons.enable = true;
        icons.package = pkgs.papirus-icon-theme;
        icons.dark = "Papirus-Dark";
        opacity = {
          terminal = appearance.opacity;
          desktop = appearance.opacity;
          popups = appearance.opacity;
          applications = appearance.opacity;
        };
        targets.plymouth.enable = true;
        targets.kmscon.enable = true;
        targets.fontconfig.enable = false;
        # see appearance.wallpaper in modules/_settings.nix
        image = let
          bg = appearance.wallpaper;
        in
          {
            local = "${self}/config/background/${bg.path or ""}";
            gruvbox = "${inputs.gruvbox-wallpapers}/${bg.path or ""}";
            tokyonight = "${inputs.tokyonight-wallpapers}/${bg.path or ""}";
            catppuccin = "${inputs.walls-catppuccin-mocha}/${bg.path or ""}";
            remote = pkgs.fetchurl {inherit (bg) url hash;};
          }
          .${
            bg.source
          };
        imageScalingMode = appearance.wallpaper.scaling;
      };
      fonts.packages = with pkgs; [
        font-awesome
        inter
      ];
      fonts.fontconfig.defaultFonts = {
        serif = [config.stylix.fonts.serif.name];
        sansSerif = [config.stylix.fonts.sansSerif.name];
        monospace = [config.stylix.fonts.monospace.name];
        emoji = [config.stylix.fonts.emoji.name];
      };
    };
    homeManager = {
      home.pointerCursor.enable = true;
    };
  };
}
