{
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
        cursor = {
          package = pkgs.capitaine-cursors-themed;
          name = "Capitaine Cursors - White";
          size = host.accessibility.cursorSize;
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
            applications = appearance.font.size + 1;
            terminal = appearance.font.size;
            desktop = appearance.font.size + 2;
            popups = appearance.font.size;
          };
        };
        icons = {
          enable = true;
          package = pkgs.papirus-icon-theme;
          dark = "Papirus-Dark";
        };
        opacity = {
          terminal = appearance.opacity;
          desktop = appearance.opacity;
          popups = appearance.opacity;
          applications = appearance.opacity;
        };
        targets = {
          plymouth.enable = true;
          kmscon.enable = true;
          fontconfig.enable = false;
        };
        # see appearance.wallpaper in modules/_settings.nix
        image = let
          bg = appearance.wallpaper;
        in
          {
            local = "${self}/config/background/${bg.path or ""}";
            gruvbox = "${inputs.gruvbox-wallpapers}/${bg.path or ""}";
            remote = pkgs.fetchurl {inherit (bg) url hash;};
          }
          .${bg.source};
        imageScalingMode = appearance.wallpaper.scaling;
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
