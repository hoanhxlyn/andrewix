{__findFile, ...}: {
  core.gaming.waydroid = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.waydroid-helper];
      # Network configuration for Waydroid
      networking.firewall.trustedInterfaces = ["waydroid0"];
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = 1;
      boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
      virtualisation.waydroid.enable = true;
      systemd.packages = [pkgs.waydroid-helper];
      systemd.services.waydroid-mount.wantedBy = ["multi-user.target"];
    };
  };
}
