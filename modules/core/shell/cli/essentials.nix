{__findFile, ...}: {
  core.cli.essentials = {
    includes = [
      (<den/batteries/unfree> ["ngrok"])
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
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      home.packages = with pkgs; [
        nps
        age
        sops
        wget
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
        direnv.enable = true;
        direnv.nix-direnv.enable = true; # cache + GC-root the flake devShell
        direnv.config.whitelist.prefix = ["${config.home.homeDirectory}/andrewix"]; # auto-trust, skip `direnv allow`
        bat.enable = true;
        ripgrep.enable = true;
        ripgrep.arguments = [
          "--hidden"
          "--glob=!.git"
        ];
        tealdeer.enable = true;
        tealdeer.enableAutoUpdates = true;
        tealdeer.settings.display.compact = false;
        tealdeer.settings.display.use_pager = true;
        tealdeer.settings.display.show_title = true;
      };

      services.wl-clip-persist.enable = true;
      services.cliphist.enable = true;
    };
  };
}
