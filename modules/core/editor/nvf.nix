{
  __findFile,
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nvf.url = "github:notashelf/nvf";

  core.editor.nvf = {
    includes = [
      (<den/unfree> ["copilot-language-server"])
    ];

    nixos = {
      pkgs,
      host,
      lib,
      ...
    }: let
      L = key: "<leader>${key}";
      mini = rec {
        explorer = false;
        picks = false;
        animate = true;
        notify = false;
        indent_scope = false;
        show_dotfiles = true;
        starter = picks; # coupled: snacks picker <-> snacks dashboard, mini.pick <-> mini.starter
      };
    in {
      imports = [inputs.nvf.nixosModules.default];
      programs.nvf = {
        enable = true;
        settings.vim = let
          cfg = import "${self}/modules/core/editor/_nvf/config.nix" {inherit host mini;};
        in {
          extraPackages = with pkgs; [
            ueberzugpp
            graphicsmagick
            graphicsmagick-imagemagick-compat
            tectonic
            mermaid-cli
            ghostscript
            stylelint
            oxlint
            kdlfmt
            vscode-langservers-extracted
            yaml-language-server
            sqlite
            tree-sitter
            prettier
            markdownlint-cli2
          ];
          viAlias = false;
          vimAlias = true;
          syntaxHighlighting = true;
          enableLuaLoader = true;
          lineNumberMode = "relNumber";
          searchCase = "smart";
          inherit (cfg) options globals clipboard;
          luaConfigRC =
            cfg.luaConfigRC
            // {
              ui2 = ''
                require("vim._core.ui2").enable({
                  enable = true,
                  msg = {
                    cmd = { height = 1 },
                    dialog = { height = 1 },
                    msg = { height = 1, timeout = 4000 },
                    pager = { height = 1 },
                    targets = "cmd",
                  },
                })
              '';
            };
          inherit
            (import "${self}/modules/core/editor/_nvf/autocmds.nix" {inherit lib mini;})
            autocmds
            augroups
            ;
          lsp = import "${self}/modules/core/editor/_nvf/lsp.nix" {inherit lib L;};
          treesitter = import "${self}/modules/core/editor/_nvf/treesitter.nix" {inherit pkgs;};
          formatter.conform-nvim = import "${self}/modules/core/editor/_nvf/formatter.nix" {inherit lib pkgs;};
          diagnostics = import "${self}/modules/core/editor/_nvf/diagnostics.nix" {inherit lib self;};
          languages = import "${self}/modules/core/editor/_nvf/languages.nix";
          ui = import "${self}/modules/core/editor/_nvf/ui.nix";
          utility = import "${self}/modules/core/editor/_nvf/utility.nix" {inherit lib mini self;};
          pluginRC = import "${self}/modules/core/editor/_nvf/plugin-rc.nix" {inherit inputs lib;};

          autocomplete.blink-cmp = import "${self}/modules/core/editor/_nvf/cmp.nix" {inherit lib;};
          mini = import "${self}/modules/core/editor/_nvf/mini.nix" {inherit lib mini self;};
          lazy = import "${self}/modules/core/editor/_nvf/lazy.nix" {inherit pkgs L;};
          keymaps = import "${self}/modules/core/editor/_nvf/keymaps.nix" {inherit L host mini lib;};
          notes.todo-comments.enable = !mini.picks;
        };
      };
    };
  };
}
