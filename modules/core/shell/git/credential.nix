{
  core.git.credential = {host, ...}: {
    homeManager = {lib, ...}: {
      programs.git-credential-keepassxc.enable = !host.wsl.enable;
      programs.git.settings.credential.helper = lib.mkIf host.wsl.enable host.windows.tools.gitCredentialManager;
    };
  };
}
