{
  lib,
  self,
  __findFile,
  ...
}: {
  den.aspects.my._.cli._ = {
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
          nps
        ];
        programs.nix-ld.enable = true;
      };
    };
    utils = {user, ...}: {
      includes = [(<den/unfree> ["ngrok"])];
      nixos = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          fuse
          usbutils
          pciutils
          wl-clipboard
          wl-clip-persist
          cliphist
          ngrok
          mockoon
        ];
        systemd.timers."refresh-nps-cache" = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "weekly"; # or however often you'd like
            Persistent = true;
            Unit = "refresh-nps-cache.service";
          };
        };

        systemd.services."refresh-nps-cache" = {
          # Make sure `nix` and `nix-env` are findable by systemd.services.
          path = ["/run/current-system/sw/"];
          serviceConfig = {
            Type = "oneshot";
            User = "${user.userName}"; # ⚠️ replace with your "username" or "${user}", if it's defined
          };
          script = ''
            set -eu
            echo "Start refreshing nps cache..."
            # ⚠️ note the use of overlay (as described above), adjust if needed
            # ⚠️ use `nps -dddd -e -r` if you use flakes
            ${pkgs.nps}/bin/nps -r -dddd
            echo "... finished nps cache with exit code $?."
          '';
        };
      };
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
