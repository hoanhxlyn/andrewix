{ pkgs, ... }:
{
  programs.zoxide.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.fastfetch.enable = true;
  programs.fd.enable = true;
  programs.bun.enable = true;
  programs.ripgrep.enable = true;
  programs.uv.enable = true;

  programs.btop = {
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
  programs.tealdeer = {
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
}
