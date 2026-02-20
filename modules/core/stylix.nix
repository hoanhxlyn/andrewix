{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.stylix = {
    terminal,
    theme,
    ...
  }: {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];
      stylix = {
        enable = true;
        autoEnable = true;
        polarity = "dark";
        opacity.terminal = terminal.opacity;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 20;
        };
        targets.firefox.profileNames = ["default"];
        targets.zen-browser.profileNames = ["default"];
        fonts = {
          monospace.package = pkgs.nerd-fonts.fira-code;
          sansSerif.package = pkgs.inter;
          serif.package = pkgs.inter;
          emoji.package = pkgs.noto-fonts-color-emoji;
          sizes = {
            applications = terminal.fontSize;
            terminal = terminal.fontSize;
            desktop = lib.add terminal.fontSize 2;
            popups = lib.add terminal.fontSize 2;
          };
        };
      };
    };
  };
}
