{__findFile, ...}: {
  den.aspects.server = {
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

    # Headless: SSH is the way in.
    nixos.services.openssh.enable = true;
  };
}
