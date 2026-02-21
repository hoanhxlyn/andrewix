{__findFile, ...}: {
  andrew.gaming.provides.steam = {
    includes = [
      (<den/unfree> [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = {pkgs, ...}: {
      hardware.graphics = {
        # Enable 32-bit graphics support for Steam games
        enable32Bit = true;
        extraPackages = with pkgs; [
          # NVIDIA Vulkan support
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
        # Add Steam to system packages (for steam-run)
        systemPackages = with pkgs; [
          steam
          steam-run
          # Additional gaming tools
          mangohud # FPS overlay
          gamemode # Performance optimization
        ];

        # Steam compatibility tools
        sessionVariables = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/usr/lib/steam/compatibilitytools.d";
        };
      };
      networking.firewall = {
        # Open firewall for Steam
        allowedTCPPorts = [
          27015
          27036
          27037 # Steam P2P, matchmaking
        ];
        allowedUDPPorts = [
          27015
          27031
          27036 # Steam P2P, voice chat
        ];
      };
    };
  };
}
