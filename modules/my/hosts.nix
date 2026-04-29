{__findFile, ...}: let
  arch = "x86_64-linux";
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
  };
  gdrive-path = "/mnt/gdrive";
in {
  den = {
    hosts.${arch} = {
      andrew-laptop.users.andrew = {};
    };
    aspects.andrew-laptop = {
      nixos = {pkgs, ...}: {
        boot.kernelParams = ["acpi_backlight=native"];
        environment.systemPackages = [pkgs.neovim pkgs.git pkgs.firefox];
      };
    };
    aspects.andrew.includes = [
      <core.bootable>
      <core.gnome>
      <core.xserver>
      <core.network>
      <core.i18n>
      <core.timezone>
      (<core.stylix> terminal)
      <core.git>
      <core.agents>
      <core.wifi>
      <core.power-manager>
      <andrew/editor/neovix>
      (<andrew/sync/rclone> gdrive-path)
      (<andrew/sync/keepassxc> gdrive-path)
      <andrew/editor/vscode>
      <andrew/editor/cursor>
      <andrew/shell>
      <andrew/browsers/firefox>
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
      <andrew/vpn/proton>
      <andrew/office/teams>
    ];
  };
}
