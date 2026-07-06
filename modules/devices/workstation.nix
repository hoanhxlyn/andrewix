{__findFile, ...}: {
  den.aspects = {
    workstation.includes = [
      (<den/batteries/import-tree/host> ../../hosts)
      <core.bootable>
      <core.disko>
      <core.desktop.xserver>
      <core.network>
      <core.i18n>
      <core.timezone>
      <core.git>
      <core.agents>
      <core.wifi>
      <core.desktop.stylix>
      <core.devices-monitors>
      <core.shell>
      <core.browsers>
      <core.communications.caprine>
      <core.communications.discord>
      <core.vpn.proton>
      <core.office.teams>
      <core.sync.rclone>
      <core.sync.keepassxc>
      # <core.editor.vscode>
      <core.editor.cursor>
      <core.terminals>
      <core.vm.podman>
      <core.office.markdown>
      <core.editor.nvf>
      <core.hardware.logitech>
    ];

    andrew-laptop.provides.to-users.includes = [
      <workstation>
      <core.desktop.wm.niri>
      <core.desktop.login>
      <core.sync.sops>
      <core.power-manager>
    ];
    andrew-pc.provides.to-users.includes = [
      <workstation>
      <core.desktop.wm.niri>
      <core.desktop.login>
      <core.sync.sops>
      <core.nvidia>
    ];
  };
}
