{__findFile, ...}: let
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
  };
  gdrive-path = "/mnt/gdrive";
in {
  den.aspects.andrew = {
    includes = [
      <andrew-wsl>
      <my/editor/neovix>
      <my/shell>
      <my/cli/essentials>
    ];
    provides.andrew-laptop = {
      includes = [
        <andrew-laptop>
        (<core.stylix> terminal)
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
        <my/cli/tui>
      ];
    };
  };
}
