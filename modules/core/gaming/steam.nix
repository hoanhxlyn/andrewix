{
  __findFile,
  self,
  ...
}: {
  core.gaming.steam = {
    includes = [
      (<den.batteries.unfree> [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = {pkgs, ...}: {
      hardware.graphics = {
        enable32Bit = true;
        extraPackages = with pkgs; [
          vulkan-tools
        ];
      };
      programs.steam = {
        enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        # SteamTinkerLaunch as a compatibility tool (steamcompattool output)
        extraCompatPackages = [pkgs.steamtinkerlaunch];
        package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            MANGOHUD_CONFIG = "position=top-right,fps";
          };
        };
      };
      programs.gamemode.enable = true;
      programs.gamescope = {
        enable = true;
        enableWsi = true;
      };
      environment.systemPackages = with pkgs; [mangohud];
    };

    homeManager = {lib, ...}: {
      # STL rewrites default_template.conf at runtime (closeSTL/updateConfigEntry),
      # so seed a writable copy instead of a store symlink. Repo wins on each switch.
      home.activation.stlSeedTemplate = lib.hm.dag.entryAfter ["writeBoundary"] ''
        install -Dm600 "${self}/config/steamtinkerlaunch/default_template.conf" \
          "$HOME/.config/steamtinkerlaunch/default_template.conf"
      '';
    };
  };
}
