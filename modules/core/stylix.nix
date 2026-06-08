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
      fonts.packages = with pkgs; [
        font-awesome
        inter
        noto-fonts-cjk-sans
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
            package = pkgs.nerd-fonts.geist-mono;
            name = "GeistMono Nerd Font";
          };
          emoji.package = pkgs.noto-fonts-color-emoji;
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
        image = pkgs.fetchurl {
          url = "https://drive.google.com/u/0/drive-viewer/AKGpiha-yv9vannCkZIH1w3mqd4yzdrTMrlIyQykEjtUGaGZcErwA7pSxDQ6g4H8xc06QG-UCGG8KZ8g9PfEX7-bPLxT_oZb_GCq6VE=s1600-rw-v1?auditContext=forDisplay";
          hash = "sha256-0k6QNfbNiRfXm1LiCKRZ0S4YU2WPMQ3Ywe6k7lI7Buk=";
        };
      };
    };
  };
}
