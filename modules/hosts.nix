{__findFile, ...}: let
  arch = "x86_64-linux";
in {
  den.hosts.${arch} = {
    andrew-laptop.users.andrew = {};
    andrew-pc.users.andrew = {};
    andrew-home-wsl = {
      wsl.enable = true;
      users.andrew = {};
      windowsName = "hoanganh";
    };
    andrew-work-wsl = {
      wsl.enable = true;
      users.andrew = {};
      windowsName = "andrew.nguyen1";
    };
  };
}
