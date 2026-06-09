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
            ];
          };
        })
    ];
    nixos = {
      programs.nix-ld.enable = true;
    };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
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
        wl-clipboard
      ];
      programs = {
        bun.enable = true;
        jq.enable = true;
      };
      services = {
        wl-clip-persist.enable = true;
        cliphist.enable = true;
      };
    };
  };
}
