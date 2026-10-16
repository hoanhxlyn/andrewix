{
  core.git.credential = {host, ...}: {
    homeManager = {lib, ...}: {
      programs = {
        git-credential-keepassxc.enable = !host.wsl.enable;
        git.settings.credential.helper = lib.mkIf host.wsl.enable "/mnt/c/Users/${host.windowsName}/scoop/root/apps/git/current/mingw64/bin/git-credential-manager.exe";
      };
    };
  };
}
