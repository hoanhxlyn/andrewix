{__findFile, ...}: {
  den.aspects = {
    wsl = {
      includes = [
        <core.git>
        <core.agents>
        <core/editor/nvf>
        <core/desktop/stylix>
        <core/shell>
        <core.sync.sops>
        <core.timezone>
        <core.vm.podman>
        <core.i18n>
      ];

      # Windows PATH entries live on a 9P/DrvFs mount, so appending them to
      # $PATH makes every command lookup (completions, prompt hooks, etc.)
      # stat across that slow mount. Interop itself stays on; only PATH
      # search is disabled, so .exe's must be invoked by absolute path.
      nixos.wsl.interop.includePath = false;

      homeManager = {pkgs, ...}: {
        home.packages = [
          (pkgs.writeShellScriptBin "wsl-open" ''
            # explorer.exe reports a spurious non-zero exit even on success.
            /mnt/c/Windows/explorer.exe "$1" 2>/dev/null
            exit 0
          '')
        ];
        home.sessionVariables.BROWSER = "wsl-open";
      };
    };

    andrew-home-wsl.provides.to-users.includes = [<wsl>];
    andrew-work-wsl.provides.to-users.includes = [<wsl>];
  };
}
