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
        pnpm
        ngrok
        mockoon
        age
        sops
        wget
        just
        jq
      ];

      programs.nix-ld.enable = true;
    };
    homeManager.programs = {
      bun.enable = true;
    };
  };
}
