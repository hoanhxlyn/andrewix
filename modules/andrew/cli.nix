{
  lib,
  self,
  ...
}: {
  den.aspects.andrew._.cli._ = {
    nodejs = {
      nixos = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          pnpm
          nodejs
        ];
      };
      homeManager.programs = {
        bun.enable = true;
      };
    };
    nix = {
      nixos = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          alejandra
          statix
          deadnix
        ];
      };
    };

    utils.nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        fuse
        usbutils
        pciutils
        wl-clipboard
        wl-clip-persist
        cliphist
      ];
    };

    tui = {
      nixos = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          pear-desktop
        ];
      };
      homeManager = {pkgs, ...}: let
        plug = pkgs.yaziPlugins;
      in {
        programs = {
          btop = {
            enable = true;
            settings = {
              color_theme = lib.mkDefault "tty";
              theme_background = false;
              vim_keys = true;
              proc_sorting = "memory";
              cpu_single_graph = true;
              show_disks = false;
            };
          };
          yazi = {
            enable = true;
            shellWrapperName = "y";
            plugins = {
              "full-border" = plug.full-border;
              "smart-enter" = plug.smart-enter;
              "lazygit" = plug.lazygit;
            };
          };
        };
        xdg.configFile."YouTube Music/config.json".force = true;
        xdg.configFile."YouTube Music/config.json".source = "${self}/config/youtube-music/config.json";
      };
    };
  };
}
