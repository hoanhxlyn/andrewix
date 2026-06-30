{__findFile, ...}: {
  core.cli.essentials = {
    includes = [
      (<den.batteries.unfree> ["ngrok"])
      <core/cli/node>
      <core/cli/tunneling>
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
        mockoon
        age
        sops
        wget
        just
        wl-clipboard
        sonar-scanner-cli
      ];
      programs = {
        jq.enable = true;
        uv.enable = true;
        eza.enable = true;
        fd.enable = true;
        fzf.enable = true;
        zoxide.enable = true;
        bat.enable = true;
        ripgrep = {
          enable = true;
          arguments = [
            "--hidden"
            "--glob=!.git"
          ];
        };
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
