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
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.caskaydia-cove
        font-awesome
        inter
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        noto-fonts
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
          sansSerif.name = "Noto Sans";
          monospace.name = "CaskaydiaCove Nerd Font";
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
          kmscon.enable = false;
        };
      };
    };
  };
}
