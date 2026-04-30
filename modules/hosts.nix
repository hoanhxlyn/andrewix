{__findFile, ...}: let
  arch = "x86_64-linux";
in {
  den.hosts.${arch} = {
    andrew-laptop.users.andrew = {};
    andrew-pc.users.andrew = {};
    andrew-wsl = {
      wsl.enable = true;
      users.andrew = {};
    };
  };
}
