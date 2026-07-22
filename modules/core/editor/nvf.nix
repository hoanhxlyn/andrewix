{
  __findFile,
  inputs,
  lib,
  self,
  ...
}: {
  flake-file.inputs.nvf.url = "github:notashelf/nvf";

  core.editor.nvf = {
    includes = [
      (<den/unfree> ["copilot-language-server"])
    ];

    homeManager.xdg.configFile."glow/glow.yml".source = "${self}/config/glow/glow.yml";

    nixos = {
      pkgs,
      host,
      ...
    }: let
      L = key: "<leader>${key}";
      mini = {
        explorer = true;
        picks = false;
        animate = true;
        notify = true;
        indent_scope = true;
        show_dotfiles = true;
      };
    in {
      imports = [inputs.nvf.nixosModules.default];
      environment.systemPackages = with pkgs; [
        ueberzugpp
        graphicsmagick
        graphicsmagick-imagemagick-compat
        tectonic
        mermaid-cli
        sqlite
        ghostscript
      ];
      programs.nvf = {
        enable = true;
        settings.vim = {
          extraPackages = with pkgs; [ueberzugpp stylelint oxlint kdlfmt vscode-langservers-extracted yaml-language-server glow sqlite tree-sitter];
          viAlias = false;
          vimAlias = true;
          syntaxHighlighting = true;
          enableLuaLoader = true; # Speed up startup (experimental)
          lineNumberMode = "relNumber"; # "relative" | "number" | "relNumber"
          searchCase = "smart";
          inherit
            (import "${self}/modules/core/editor/_nvf/config.nix" {inherit host mini;})
            options
            globals
            clipboard
            luaConfigRC
            ;
          inherit
            (import "${self}/modules/core/editor/_nvf/autocmds.nix" {inherit lib;})
            autocmds
            augroups
            ;
          lsp = import "${self}/modules/core/editor/_nvf/lsp.nix" {inherit lib L;};
          treesitter = import "${self}/modules/core/editor/_nvf/treesitter.nix" {inherit pkgs;};
          formatter.conform-nvim = import "${self}/modules/core/editor/_nvf/formatter.nix" {inherit lib pkgs;};
          diagnostics = import "${self}/modules/core/editor/_nvf/diagnostics.nix" {inherit lib;};
          languages = import "${self}/modules/core/editor/_nvf/languages.nix";
          ui = import "${self}/modules/core/editor/_nvf/ui.nix";
          utility = import "${self}/modules/core/editor/_nvf/utility.nix" {inherit lib mini;};
          pluginRC = import "${self}/modules/core/editor/_nvf/plugin-rc.nix" {inherit inputs lib;};

          autocomplete.blink-cmp = import "${self}/modules/core/editor/_nvf/cmp.nix" {inherit lib;};
          mini = import "${self}/modules/core/editor/_nvf/mini.nix" {inherit lib mini self;};
          lazy = import "${self}/modules/core/editor/_nvf/lazy.nix" {inherit pkgs L;};
          keymaps = import "${self}/modules/core/editor/_nvf/keymaps.nix" {inherit L host mini;};
          notes.todo-comments.enable = !mini.picks; # Snacks todo_comments picker needs folke plugin; highlights via mini when picks=true
        };
      };
    };
  };
}
