{
  den,
  __findFile,
  ...
}: {
  den.aspects = {
    workstation.includes = [
      (den._.import-tree._.host ../../hosts)
      <core.bootable>
      <core.disko>
      <core.gnome>
      <core.xserver>
      <core.network>
      <core.i18n>
      <core.timezone>
      <core.git>
      <core.agents>
      <core.wifi>
      <core.stylix>
      <my/editor/neovix>
      <my/shell>
      <my/cli/essentials>
      <my/cli/tui>
      <my/browsers/firefox>
      <my/communications/caprine>
      <my/communications/discord>
      <my/vpn/proton>
      <my/office/teams>
      <my/browsers/zen>
      <my/browsers/brave> # Need a chromium for web dev
      <my/sync/rclone>
      <my/sync/keepassxc>
      <my/editor/vscode>
      <my/editor/cursor>
    ];
    andrew-laptop.provides.to-users.includes = [
      <workstation>
      <my/terminals/alacritty>
      <core.power-manager>
    ];
    andrew-pc.provides.to-users.includes = [
      <workstation>
      <core.nvidia>
      <my/terminals/alacritty>
    ];
  };
}
