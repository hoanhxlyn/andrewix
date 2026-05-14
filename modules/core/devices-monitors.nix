{__findFile, ...}: {
  core.devices-monitors = {
    # includes = [
    #   (<den.batteries.unfree> ["cuda-merged" "cuda_cuobjdump" "cuda_gdb" "cuda_nvcc" "cuda_nvdisasm"])
    # ];
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
