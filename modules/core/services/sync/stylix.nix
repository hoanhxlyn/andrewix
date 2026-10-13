{
  lib,
  inputs,
  self,
  ...
}: {
  flake-file.inputs.stylix = {
    # fork = master + stylix#2501 (rofi settings.font rename), revert khi merge
    # https://github.com/nix-community/stylix/pull/2501
    url = "github:adomixaszvers/stylix/merged-rofi-settings-font";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.gruvbox-wallpapers = {
    url = "github:AngelJumbo/gruvbox-wallpapers";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.services.sync.stylix = {host, ...}: let
    inherit (host) terminal;
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
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
        polarity = "dark";
        cursor = {
          package = pkgs.capitaine-cursors-themed;
          name = "Capitaine Cursors - White";
          size = lib.mul terminal.fontSize 2;
        };
        fonts = {
          serif = config.stylix.fonts.sansSerif;
          sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          monospace = {
            package = pkgs.nerd-fonts.caskaydia-cove;
            name = "CaskaydiaCove Nerd Font";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            applications = terminal.fontSize + 1;
            terminal = terminal.fontSize;
            desktop = terminal.fontSize + 2;
            popups = terminal.fontSize + 2;
          };
        };
        icons = {
          enable = true;
          package = pkgs.papirus-icon-theme;
          dark = "Papirus-Dark";
        };
        opacity = {
          terminal = terminal.opacity;
          desktop = terminal.opacity;
          popups = terminal.opacity;
          applications = terminal.opacity;
        };
        targets = {
          plymouth.enable = true;
          kmscon.enable = true;
          fontconfig.enable = false;
        };
        # string = file in config/background/; { gruvbox = "<path in repo>"; }
        # = AngelJumbo/gruvbox-wallpapers (no hash); { url; hash; } = anywhere else
        image =
          if builtins.isAttrs host.backgroundImage
          then
            if host.backgroundImage ? url
            then pkgs.fetchurl host.backgroundImage
            else "${inputs.gruvbox-wallpapers}/${host.backgroundImage.gruvbox}"
          else "${self}/config/background/${host.backgroundImage}";
        imageScalingMode = "center"; # fill | center | stretch | fit
      };
      fonts = {
        packages = with pkgs; [
          font-awesome
          inter
        ];
        fontconfig.defaultFonts = {
          serif = [config.stylix.fonts.serif.name];
          sansSerif = [config.stylix.fonts.sansSerif.name];
          monospace = [config.stylix.fonts.monospace.name];
          emoji = [config.stylix.fonts.emoji.name];
        };
      };
    };
    homeManager = {
      home.pointerCursor.enable = true;
    };
  };
}
