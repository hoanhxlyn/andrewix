{__findFile, ...}: {
  den.aspects.andrew-laptop = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.neovim pkgs.git pkgs.firefox];
    };
    includes = [
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
}
