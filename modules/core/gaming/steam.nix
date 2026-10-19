{__findFile, ...}: {
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
  };
}
