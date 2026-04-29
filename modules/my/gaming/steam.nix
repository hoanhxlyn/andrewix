{__findFile, ...}: {
  den.aspects.my._.gaming._.steam = {
    includes = [
      (<den/unfree> [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = {pkgs, ...}: {
      hardware.graphics = {
        enable32Bit = true;
        extraPackages = with pkgs; [
          vulkan-validation-layers
          vulkan-tools
        ];
      };
      programs = {
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
        gamemode.enable = true;
      };
      environment = {
        systemPackages = with pkgs; [
          steam
          steam-run
          mangohud
          gamemode
        ];
        sessionVariables = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/usr/lib/steam/compatibilitytools.d";
        };
      };
      networking.firewall = {
        allowedTCPPorts = [
          27015
          27036
          27037
        ];
        allowedUDPPorts = [
          27015
          27031
          27036
        ];
      };
    };
  };
}
