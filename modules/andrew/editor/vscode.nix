{
  lib,
  self,
  __findFile,
  ...
}: {
  andrew.editor.provides.vscode = {
    includes = [
      (<den/unfree> ["vscode"])
    ];
    homeManager = {pkgs, ...}: {
      programs.vscode = {
        enable = true;
        profiles.default = {
          userSettings = lib.importJSON "${self}/config/vscode/settings.json";
          keybindings = lib.importJSON "${self}/config/vscode/keybindings.json";
          enableMcpIntegration = true;
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          extensions = with pkgs.vscode-extensions; [
            # TODO: add more here
            jnoortheen.nix-ide
            biomejs.biome
            sumneko.lua
            dbaeumer.vscode-eslint
            bradlc.vscode-tailwindcss
            prettier.prettier-vscode
            eamodio.gitlens
            stylelint.vscode-stylelint
            formulahendry.auto-rename-tag
            christian-kohler.path-intellisense
            editorconfig.editorconfig
            usernamehw.errorlens
            yoavbls.pretty-ts-errors
            jgclark.vscode-todo-highlight
            prisma.prisma
            github.vscode-pull-request-github
            gitlab.gitlab-workflow
            zguolee.tabler-icons
            vscode-icons-team.vscode-icons
          ];
        };
      };
    };
  };
}
