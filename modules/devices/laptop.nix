{
  den,
  __findFile,
  ...
}: let
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
  };
  gdrive-path = "/mnt/gdrive";
in {
  den.aspects.andrew-laptop = {
    provides.to-users.includes = [
      (den._.import-tree._.host ../../hosts)
      <core.bootable>
      <core.gnome>
      <core.xserver>
      <core.network>
      <core.i18n>
      <core.timezone>
      <core.git>
      <core.agents>
      <core.wifi>
      <core.power-manager>
      (<core.stylix> terminal)
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
      (<my/terminals/alacritty> terminal)
      (<my/terminals/wezterm> terminal)
      (<my/sync/rclone> gdrive-path)
      (<my/sync/keepassxc> gdrive-path)
      <my/editor/vscode>
      <my/editor/cursor>
    ];
  };
}
