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
      hardware.graphics = {
        enable32Bit = true;
        extraPackages = with pkgs; [
          vulkan-tools
        ];
      };
      programs.steam = {
        enable = true;
        protontricks.enable = true;
        extraCompatPackages = [inputs.dw-proton.packages.${pkgs.stdenv.hostPlatform.system}.dw-proton];
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
