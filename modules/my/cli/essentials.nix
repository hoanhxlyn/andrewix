{__findFile, ...}: {
  den.aspects.my.cli.essentials = {
    includes = [
      (<den.batteries.unfree> ["ngrok"])
      <my/cli/node>
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
        ngrok
        mockoon
        age
        sops
        wget
        just
        wl-clipboard
      ];
      programs = {
        jq.enable = true;
        uv.enable = true;
        eza.enable = true;
        fd.enable = true;
        fzf.enable = true;
        zoxide.enable = true;
        bat.enable = true;
        ripgrep.enable = true;
        tealdeer = {
          enable = true;
          enableAutoUpdates = true;
          settings.display = {
            compact = false;
            use_pager = true;
            show_title = true;
          };
        };
      };

      services = {
        wl-clip-persist.enable = true;
        cliphist.enable = true;
      };
    };
  };
}
