{__findFile, ...}: {
  den.aspects.my._.cli._.essentials = {
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
