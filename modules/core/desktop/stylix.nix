{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.desktop.stylix = {host, ...}: let
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
      fonts.packages = with pkgs; [
        font-awesome
        inter
      ];
      stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
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
            package = pkgs.nerd-fonts.geist-mono;
            name = "GeistMono Nerd Font";
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
          url = "https://files.orangc.net/media/walls-catppuccin-mocha/oversized-cat.jpg";
          sha256 = "0c9fkhixpzh6hvwbqvfrfsi7c5p1lwnaql6ri1kkdjahay1h0spl";
        };
        imageScalingMode = "fill"; # fill | center | stretch | fit
      };
    };
  };
}
