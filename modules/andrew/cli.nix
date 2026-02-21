{lib, ...}: {
  andrew.cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        fuse
        usbutils
        pciutils
        wl-clipboard
        wl-clip-persist
        cliphist
        pnpm
        nodePackages.nodejs
        bun
      ];
    };
    homeManager = {
      programs = {
        fastfetch.enable = true;
        bun.enable = true;
        eza.enable = true;
        fd.enable = true;
        fzf.enable = true;
        zoxide.enable = true;
        bat.enable = true;
        ripgrep.enable = true;
        uv.enable = true;
        nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep-since 2d --keep 5";
          flake = "/home/andrew/andrewix";
        };
        btop = {
          enable = true;
          settings = {
            color_theme = lib.mkDefault "tty";
            theme_background = false;
            vim_keys = true;
            proc_sorting = "memory";
            cpu_single_graph = true;
            show_disks = false;
          };
        };
        tealdeer = {
          enable = true;
          enableAutoUpdates = true;
          settings = {
            display = {
              compact = false;
              use_pager = true;
              show_title = true;
            };
          };
        };
      };
    };
  };
}
