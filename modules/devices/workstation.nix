{__findFile, ...}: {
  den.aspects = {
    workstation.includes = [
      (<den/batteries/import-tree/host> ../../hosts)
      <core.bootable>
      <core.disko>
      <core.xserver>
      <core.network>
      <core.i18n>
      <core.timezone>
      <core.git>
      <core.agents>
      <core.wifi>
      <core.stylix>
      <core.devices-monitors>
      <my/shell>
      <my/cli/essentials>
      <my/cli/tui>
      <my/browsers/firefox>
      <my/communications/caprine>
      <my/communications/discord>
      <my/vpn/proton>
      <my/office/teams>
      <my/browsers/zen>
      <my/browsers/helium>
      <my/sync/rclone>
      <my/sync/keepassxc>
      <my/sync/sops>
      <my/editor/vscode>
      <my/editor/cursor>
      <my/terminals/ghostty>
      <my/vm/podman>
      <my/office/markdown>
      <my/editor/nvf>
    ];

    andrew-laptop.provides.to-users.includes = [
      <workstation>
      <my/de/gnome>
      <core.power-manager>
    ];
    andrew-pc.provides.to-users.includes = [
      <workstation>
      <my/de/gnome>
      # <my/wm/niri>
      <core.nvidia>
    ];
  };
}
