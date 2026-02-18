{pkgs, ...}: {
  # Enable Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable 32-bit graphics support for Steam games
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    # NVIDIA Vulkan support
    vulkan-validation-layers
    vulkan-tools
  ];

  # Add Steam to system packages (for steam-run)
  environment.systemPackages = with pkgs; [
    steam
    steam-run
    # Additional gaming tools
    mangohud # FPS overlay
    gamemode # Performance optimization
  ];

  # Enable GameMode for better performance
  programs.gamemode.enable = true;

  # Steam compatibility tools
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/usr/lib/steam/compatibilitytools.d";
  };

  # Open firewall for Steam
  networking.firewall.allowedTCPPorts = [
    27015
    27036
    27037 # Steam P2P, matchmaking
  ];
  networking.firewall.allowedUDPPorts = [
    27015
    27031
    27036 # Steam P2P, voice chat
  ];
}
