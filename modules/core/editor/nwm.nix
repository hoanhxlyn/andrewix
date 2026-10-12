{
  inputs,
  self,
  __findFile,
  ...
}: {
  flake-file.inputs = {
    nwm = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mini-nvim = {
      url = "github:nvim-mini/mini.nvim";
      flake = false;
    };
  };

  core.editor.nwm = {
    nixos = {pkgs, ...}: {
      imports = [
        (inputs.nwm.lib.getInstallModule {
          name = "nvim";
          value = inputs.nwm.lib.wrapperModules.neovim;
        })
      ];

      wrappers.nvim = {config, ...}: {
        enable = true;
        settings = {
          aliases = ["vim" "vi"];
          config_directory = "${self}/config/nvim";
        };
        specs.general = with pkgs.vimPlugins; [
          lz-n
          (config.nvim-lib.mkPlugin "mini-nvim" inputs.mini-nvim)
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
          nvim-treesitter-context
          nvim-ts-context-commentstring
          plenary-nvim
          SchemaStore-nvim
        ];
        specs.lazy = {
          lazy = true;
          data = with pkgs.vimPlugins; [
            nvim-lspconfig
            lazydev-nvim
            blink-cmp
            friendly-snippets
            nvim-lint
            conform-nvim
            nvim-dap
            nvim-nio
            nvim-dap-ui
            nvim-dap-virtual-text
            nvim-navic
            nvim-ufo
            promise-async
            markview-nvim
            nvim-colorizer-lua
            nvim-ts-autotag
            bufferline-nvim
            lualine-nvim
            which-key-nvim
          ];
        };
        runtimePkgs = with pkgs; [
          # LSPs
          nil
          lua-language-server
          vscode-langservers-extracted
          yaml-language-server
          tailwindcss-language-server
          typescript # tsc 7 native LSP (`tsc --lsp`)
          fish-lsp
          marksman
          taplo
          biome
          # Formatters
          alejandra
          stylua
          prettier
          shfmt
          kdlfmt
          markdownlint-cli2
          yamlfix
          # Linters
          stylelint
          # Debug
          vscode-js-debug
        ];
      };
    };
  };
}
