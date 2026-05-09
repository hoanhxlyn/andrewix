{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.stylix = terminal: {
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
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";
        polarity = "dark";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };
        fonts = {
          serif = config.stylix.fonts.sansSerif;
          sansSerif.name = "Noto Sans";
          monospace.name = "FiraCode Nerd Font";
          emoji.package = pkgs.noto-fonts-color-emoji;
          sizes = {
            applications = terminal.fontSize + 2;
            terminal = terminal.fontSize;
            desktop = lib.add terminal.fontSize 2;
            popups = lib.add terminal.fontSize 2;
          };
        };
        opacity.terminal = terminal.opacity;
        targets.plymouth.enable = true;
      };
    };
  };
}
