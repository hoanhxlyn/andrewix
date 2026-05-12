{__findFile, ...}: let
  arch = "x86_64-linux";
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
  };
  gdrive-path = "/mnt/gdrive";
in {
  den.hosts.${arch} = {
    andrew-laptop = {
      inherit terminal;
      inherit gdrive-path;
      users.andrew = {};
    };
    andrew-pc = {
      inherit terminal;
      inherit gdrive-path;
      users.andrew = {};
    };
    andrew-home-wsl = {
      wsl.enable = true;
      users.andrew = {};
      inherit terminal;
      windowsName = "hoanganh";
    };
    andrew-work-wsl = {
      wsl.enable = true;
      users.andrew = {};
      inherit terminal;
      windowsName = "andrew.nguyen1";
    };
  };
}
