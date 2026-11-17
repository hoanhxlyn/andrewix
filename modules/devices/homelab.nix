{__findFile, ...}: {
  den.aspects.homelab = {
    includes = [
      <core.hardware>
      # Stylix is a dependency of the aspects below (bootable sets
      # stylix.targets.grub, i18n sets stylix.targets.fcitx5, herdr/kitty read
      # config.lib.stylix.*), so a headless host still needs it.
      <core.services.sync.stylix>
      <core.services.sync.sops>
      <core.services.sync.rclone>
      <core.services.sync.keepassxc>
      <core.services.gradient>
      <core.services.tailscale>
      <core.locale>
      <core.git>
      <core.agents>
      <core.shell>
      <core.editor>
      <core.terminals>
      <core.desktop.wm.niri>
      <core.desktop.login>
      <core.browsers.helium>
      <core.browsers.xdg>
    ];

    # Server: SSH is the way in from elsewhere, but only over the tailnet. The default firewall rule
    # for port 22 is off, so LAN and WAN interfaces never see sshd.
    nixos = {
      config,
      user,
      ...
    }: {
      # Register with the tailnet as "andrewix".
      services.tailscale.extraUpFlags = ["--hostname=andrewix"];
      services.openssh.enable = true;
      services.openssh.openFirewall = false;
      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [22];
      users.users.${user.userName}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPnUeg3dyZHHyYTuW43Kf+iteolCgWMIdBQR7t+rJ9nD andrew@home-pc"
      ];
    };
  };
}
