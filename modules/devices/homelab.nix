{__findFile, ...}: {
  den.aspects.homelab = {
    includes = [
      <core.hardware>
      # Stylix is a dependency of the aspects below (bootable sets
      # stylix.targets.grub, i18n sets stylix.targets.fcitx5, herdr/kitty read
      # config.lib.stylix.*), so a headless host still needs it.
      <core.services.sync.stylix>
      <core.services.sync.sops>
      <core.services.attic>
      <core.services.tailscale>
      <core.locale>
      <core.git>
      <core.agents>
      <core.shell>
      <core.editor>
      <core.terminals>
    ];

    # Headless: SSH is the way in, but only over the tailnet. The default firewall rule
    # for port 22 is off, so LAN and WAN interfaces never see sshd.
    nixos = {config, ...}: {
      services.openssh = {
        enable = true;
        openFirewall = false;
      };
      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [22];
    };
  };
}
