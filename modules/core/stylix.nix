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
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
        polarity = "dark";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 20;
        };
        fonts = {
          monospace = {
            name = "CaskaydiaCove Nerd Font";
          };
          emoji.package = pkgs.noto-fonts-color-emoji;
          sizes = {
            applications = terminal.fontSize;
            terminal = terminal.fontSize;
            desktop = lib.add terminal.fontSize 2;
            popups = lib.add terminal.fontSize 2;
          };
        };
        targets.plymouth.enable = true;
      };
    };
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      stylix = {
        enable = true;
        autoEnable = true;
        # opacity.terminal = terminal.opacity;
        targets.firefox.profileNames = ["default"];
        targets.zen-browser.profileNames = ["default"];
      };
    };
  };
}
