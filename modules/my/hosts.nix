{__findFile ? __findFile, ...}: let
  arch = "x86_64-linux";
  username = "andrew";
in {
  den = {
    hosts.${arch} = {
      andrew-laptop = {
        description = "Personal laptop";
        users.${username}.aspect = "laptop";
      };
      andrew-pc = {
        description = "Personal pc";
        users.${username}.aspect = "pc";
      };
    };

    homes.${arch}.${username} = {};

    aspects = {
      ${username}.includes = [<my/user>];
      laptop.includes = [
        <core.bootable>
        <core.gnome>
        <core.fonts>
        <core.xserver>
        <core.network>
        <core.i18n>
      ];
      pc.includes = [
        <core.bootable>
        <core.gnome>
        <core.fonts>
        <core.xserver>
        <core.network>
        <core.i18n>
        <core.nvidia>
      ];
    };
  };
}
