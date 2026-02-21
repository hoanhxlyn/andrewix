{__findFile, ...}: {
  andrew.editor.provides.vscode = {
    includes = [
      (<den/unfree> ["vscode-extension-github-copilot"])
    ];
    homeManager = {pkgs, ...}: {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        profiles.default = {
          userSettings = {
            # TODO: add more here
            "files.autoSave" = "off";
            "editor.formatOnSave" = true;
            "editor.tabSize" = 2;
            "editor.mouseWheelZoom" = true;
            "workbench.activityBar.location" = "top";
            "window.menuBarVisibility" = "compact";
            "workbench.navigationControl.enabled" = false;
            "workbench.layoutControl.enabled" = false;
            "security.workspace.trust.enabled" = false;
            "[jsonc]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            # Extension stuff
            "biome.suggestInstallingGlobally" = false;
            "biome.requireConfiguration" = true;
          };
          enableMcpIntegration = true;
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = with pkgs.vscode-extensions; [
            # TODO: add more here
            bbenoist.nix
            biomejs.biome
            sumneko.lua
            dbaeumer.vscode-eslint
            bradlc.vscode-tailwindcss
            prettier.prettier-vscode
            eamodio.gitlens
            stylelint.vscode-stylelint
            formulahendry.auto-rename-tag
            christian-kohler.path-intellisense
            github.copilot
            github.copilot-chat
          ];
        };
      };
    };
  };
}
