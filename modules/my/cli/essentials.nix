{__findFile, ...}: {
  den.aspects.my.cli.essentials = {
    includes = [
      (<den.batteries.unfree> ["ngrok"])
      ({host, ...}:
        if host.wsl.enable
        then {}
        else {
          nixos = {pkgs, ...}: {
            environment.systemPackages = with pkgs; [
              fuse
              usbutils
              pciutils
              wl-clipboard
              wl-clip-persist
              cliphist
            ];
          };
        })
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        alejandra
        statix
        deadnix
        nps
        nodejs_latest
        pnpm
        ngrok
        mockoon
        age
        sops
        wget
        just
      ];
      programs = {
        nix-ld.enable = true;
      };
    };
    homeManager.programs = {
      bun.enable = true;
    };
  };
}
