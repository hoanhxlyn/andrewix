{
  inputs,
  self,
  __findFile,
  ...
}: {
  flake-file.inputs = {
    import-size-nvim = {
      url = "github:stuckinsnow/import-size.nvim";
      flake = false;
    };
    wezterm-types = {
      url = "github:justinsgithub/wezterm-types";
      flake = false;
    };
    vim-rzip = {
      url = "github:lbrayner/vim-rzip";
      flake = false;
    };
  };
  andrew.editor.provides.neovix = {
    includes = [
      (<den/unfree> [
        "copilot-language-server"
      ])
    ];
    homeManager = {pkgs, ...}: {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        vimdiffAlias = true;

        plugins = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (p: [
            p.lua
            p.vim
            p.vimdoc
            p.bash
            p.diff
            p.html
            p.css
            p.powershell
            p.javascript
            p.typescript
            p.tsx
            p.regex
            p.jsdoc
            p.json
            p.query
            p.git_rebase
            p.gitcommit
            p.git_config
            p.markdown
            p.markdown_inline
            p.toml
            p.xml
            p.yaml
            p.fish
            p.kdl
            p.nix
          ]))
          nvim-treesitter-textobjects
          nvim-treesitter-context

          # Plugins
          mini-nvim
          snacks-nvim
          nvim-lspconfig
          todo-comments-nvim
          nvim-ts-context-commentstring
          nvim-ts-autotag
          bufferline-nvim
          nvim-lint
          sidekick-nvim
          blink-cmp
          conform-nvim
          nvim-navic
          lazydev-nvim
          friendly-snippets
          blink-copilot
          nvim-ufo
          promise-async
          SchemaStore-nvim
          plenary-nvim
          tokyonight-nvim
          gruvbox-material-nvim
          gruvbox-nvim
          kanagawa-nvim
          catppuccin-nvim
          rose-pine
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
          (pkgs.vimUtils.buildVimPlugin {
            name = "import-size-nvim";
            src = inputs.import-size-nvim;
          })
          (pkgs.vimUtils.buildVimPlugin {
            name = "wezterm-types";
            src = inputs.wezterm-types;
          })
          (pkgs.vimUtils.buildVimPlugin {
            name = "vim-rzip";
            src = inputs.vim-rzip;
          })
        ];

        extraPackages = with pkgs; [
          mermaid-cli
          ghostscript
          tectonic
          imagemagick
          gcc
          tree-sitter
          alejandra
          stylua
          biome
          shfmt
          yamlfix
          prettierd
          markdownlint-cli2
          eslint
          taplo
          kdlfmt
          cspell
          stylelint
          lsof
          vtsls
          lua-language-server
          tailwindcss-language-server
          vscode-langservers-extracted
          yaml-language-server
          nil
          vscode-js-debug
          fish-lsp
        ];
      };

      xdg.configFile.nvim = {
        source = "${self}/config/neovix";
        recursive = true;
      };
    };
  };
}
