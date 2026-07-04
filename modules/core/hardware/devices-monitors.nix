{__findFile, ...}: {
  core.devices-monitors = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        lm_sensors
        hddtemp
      ];
    };
    homeManager = {lib, ...}: {
      programs.btop = {
        enable = true;
        settings = {
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
  };
}
