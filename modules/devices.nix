{
  den,
  __findFile,
  ...
}: {
  den.aspects.andrew-laptop = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.neovim pkgs.git pkgs.firefox];
    };
    includes = [
      (den._.import-tree._.host ../hosts)
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
    ];
  };
  den.aspects.andrew-wsl = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.neovim pkgs.git];
    };
    includes = [
      <core.agents>
      <core.git>
    ];
  };
}
