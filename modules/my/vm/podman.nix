{
  den.aspects.my.vm.podman = {
    nixos = {
      virtualisation = {
        containers = {
          enable = true;
          containersConf.settings.engine.compose_warning_logs = false;
          registries.search = ["docker.io"];
        };
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
          dockerSocket.enable = true;
        };
      };
      boot.kernel.sysctl."vm.max_map_count" = 524288;
    };

    homeManager = {pkgs, ...}: {
      # Useful other development tools
      home.packages = with pkgs; [
        dive
        # docker-compose # start group of containers for dev
        podman-compose # start group of containers for dev
      ];
      programs.lazydocker.enable = true;
    };
  };
}
