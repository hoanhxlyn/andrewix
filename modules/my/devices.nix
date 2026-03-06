{__findFile ? __findFile, ...}: let
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
  };
  git = {
    settings = {
      user.email = "hoanhxlyn@gmail.com";
      user.name = "Andrew Nguyen";
    };
    editor = "nvim";
  };
  gdrive-path = "/mnt/gdrive";
  theme = "gruvbox-dark";
in {
  my.devices.provides = {
    base.includes = [
      <core.bootable>
      <core.gnome>
      <core.fonts>
      <core.xserver>
      <core.network>
      <core.i18n>
      <core.timezone>
      (<core.stylix> {
        inherit terminal;
        inherit theme;
      })
      (<core.git> git)
      <core.agents>
      (<andrew/sync/rclone> gdrive-path)
      (<andrew/sync/keepassxc> gdrive-path)

      <andrew/editor/neovix>
      # <andrew/editor/zed> # Doesn't really benefit much for me
      <andrew/editor/vscode>
      <andrew/shell>
      # <andrew/browsers/firefox>
      <andrew/browsers/zen>
      <andrew/browsers/brave> # Need a chromium for web dev
      (<andrew/terminals/alacritty> terminal)
      (<andrew/terminals/wezterm> terminal)
      <andrew/cli/nodejs>
      <andrew/cli/nix>
      <andrew/cli/utils>
      <andrew/cli/tui>
      <andrew/communications/caprine>
      <andrew/communications/discord>
    ];
    home-laptop.includes = [
      <my.devices/base>
      <core.wifi>
      <core.power-manager>
    ];
    home-pc.includes = [
      <my.devices/base>
      <core.nvidia>
      <andrew/gaming/steam>
      <andrew/gaming/xone>
    ];
  };
}
