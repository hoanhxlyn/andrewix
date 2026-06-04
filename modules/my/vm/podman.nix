{
  den.aspects.my.vm.podman = {
    nixos = {
      # Enable common container config files in /etc/containers
      virtualisation.containers.enable = true;
      virtualisation = {
        podman = {
          enable = true;
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;
          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };
      # Run podman as systemd services
      # virtualisation.oci-containers.backend = "podman";
      # virtualisation.oci-containers.containers = {
      #   container-name = {
      #     image = "container-image";
      #     autoStart = true;
      #     ports = ["127.0.0.1:1234:1234"];
      #   };
      # };
    };
    homeManager = {pkgs, ...}: {
      # Useful other development tools
      home.packages = with pkgs; [
        dive # look into docker image layers
        podman-tui # status of containers in the terminal
        # docker-compose # start group of containers for dev
        podman-compose # start group of containers for dev
      ];
      programs.lazydocker.enable = true;
    };
  };
}
