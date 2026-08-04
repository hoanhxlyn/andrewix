{__findFile, ...}: {
  den.aspects = {
    workstation.includes = [
      (<den/batteries/import-tree/host> ../../hosts)
      <core.bootable>
      <core.sound>
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
      <core.media>
      <core.communications.discord>
      <core.vpn.proton>
      <core.office.libreoffice>
      <core.office.teams>
      <core.office.timr-tui>
      <core.sync.rclone>
      <core.sync.keepassxc>
      # <core.editor.vscode>
      <core.editor.cursor>
      <core.terminals>
      <core.vm.podman>
      <core.office.markdown>
      <core.editor.nvf>
      <core.hardware.logitech>
      <core.desktop.login>
      <core.sync.sops>
      <core.desktop.wm.niri>
    ];

    andrew-laptop.provides.to-users.includes = [
      <workstation>
      <core.power-manager>
    ];
    andrew-pc.provides.to-users.includes = [
      <workstation>
      <core.nvidia>
    ];
  };
}
