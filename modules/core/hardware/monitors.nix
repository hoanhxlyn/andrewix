{__findFile, ...}: {
  core.hardware.monitors = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        lm_sensors
        smartmontools
      ];
    };
    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.duf];
      programs.btop.enable = true;
      programs.btop.settings = {
        color_theme = lib.mkDefault "tty";
        theme_background = false;
        vim_keys = true;
        proc_sorting = "memory";
        cpu_single_graph = true;
        show_disks = true;
        shown_boxes = "cpu mem proc";
      };
    };
  };
}
