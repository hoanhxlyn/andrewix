{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
  ];

  programs = {
    zoxide.enable = true;
    bat.enable = true;
    eza.enable = true;
    fzf.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    bun.enable = true;
    ripgrep.enable = true;
    uv.enable = true;

    btop = {
      enable = true;
      settings = {
        color_theme = "tty";
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
}
