{
  __findFile,
  inputs,
  ...
}: {
  # kernel-level ACE anti-cheat only passes under DW-Proton for Wuthering Waves
  flake-file.inputs.dw-proton = {
    url = "github:imaviso/dwproton-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.gaming.steam = {
    includes = [
      (<den.batteries.unfree> [
        "steam"
        "steam-unwrapped"
      ])
    ];
    nixos = {pkgs, ...}: {
      hardware.graphics.enable32Bit = true;
      hardware.graphics.extraPackages = with pkgs; [
        vulkan-tools
      ];
      programs.steam = {
        enable = true;
        protontricks.enable = true;
        extraCompatPackages = [inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton];
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
      programs.gamemode.enable = true;
      programs.gamescope.enable = true;
      programs.gamescope.enableWsi = true;
      environment.systemPackages = with pkgs; [mangohud];
    };
    # Wrap the Steam client once: every game inherits the nested gamescope display and, on a
    # hybrid host, the NVIDIA offload env, so no per-game launch options are needed. -w/-h is
    # what games render at (1080p, the gaming hosts' panel); -W/-H defaults to 720p otherwise.
    homeManager = {
      host,
      lib,
      ...
    }: let
      gpus = host.gpu;
      hybrid =
        lib.any (g: g.vendor == "nvidia" && g.kind == "discrete") gpus
        && lib.any (g: g.vendor == "intel" && g.kind == "integrated") gpus;
      gamescope = "${lib.optionalString hybrid "nvidia-offload "}gamescope -w 1920 -h 1080 -W 1920 -H 1080 -f";
    in {
      # User-level entry shadows the packaged steam.desktop, so launchers and steam:// URLs use it.
      xdg.desktopEntries.steam = {
        name = "Steam";
        comment = "Steam client, every game nested in gamescope";
        icon = "steam";
        exec = "${gamescope} -- steam %U";
        terminal = false;
        categories = ["Network" "FileTransfer" "Game"];
        mimeType = ["x-scheme-handler/steam" "x-scheme-handler/steamlink"];
      };
    };
  };
}
