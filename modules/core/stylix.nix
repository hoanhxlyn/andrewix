{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.stylix = {host, ...}: let
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
      fonts.fontconfig.defaultFonts.emoji = ["Noto Color Emoji"];
      fonts.packages = with pkgs; [
        font-awesome
        inter
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];
      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
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
            applications = lib.add terminal.fontSize 1;
            terminal = lib.add terminal.fontSize 0;
            desktop = lib.add terminal.fontSize 2;
            popups = lib.add terminal.fontSize 2;
          };
        };
        opacity = {
          terminal = terminal.opacity;
          desktop = terminal.opacity;
          popups = terminal.opacity;
          applications = terminal.opacity;
        };
        targets = {
          plymouth.enable = true;
          nvf.transparentBackground = true;
          kmscon.enable = true;
        };
        image = builtins.fetchurl {
          url = "https://wallpaperaccess.com/full/12259305.png";
          sha256 = "1ncgi241qfsnkj2c5mdh14fhfk45hh00ciy85czfl1qxpj3mvh6q";
        };
        imageScalingMode = "fill"; # fill | center | stretch | fit
      };
    };
  };
}
