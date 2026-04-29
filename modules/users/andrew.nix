{__findFile, ...}: let
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
  };
  gdrive-path = "/mnt/gdrive";
in {
  den.aspects.andrew.includes = [
    <andrew-laptop>
    (<core.stylix> terminal)
    <my/editor/neovix>
    (<my/sync/rclone> gdrive-path)
    (<my/sync/keepassxc> gdrive-path)
    <my/editor/vscode>
    <my/editor/cursor>
    <my/shell>
    <my/browsers/firefox>
    <my/browsers/zen>
    <my/browsers/brave> # Need a chromium for web dev
    (<my/terminals/alacritty> terminal)
    (<my/terminals/wezterm> terminal)
    <my/cli/nodejs>
    <my/cli/nix>
    <my/cli/utils>
    <my/cli/tui>
    <my/communications/caprine>
    <my/communications/discord>
    <my/vpn/proton>
    <my/office/teams>
  ];
}
