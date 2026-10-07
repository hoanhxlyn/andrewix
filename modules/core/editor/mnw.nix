{
  inputs,
  self,
  __findFile,
  ...
}: {
  flake-file.inputs = {
    mnw.url = "github:Gerg-L/mnw";
    mini-nvim = {
      url = "github:nvim-mini/mini.nvim";
      flake = false;
    };
  };

  core.editor.mnw = {
    nixos = {pkgs, ...}: {
      imports = [inputs.mnw.nixosModules.default];
      programs.mnw = let
        mini-nvim-latest = pkgs.vimUtils.buildVimPlugin {
          pname = "mini-nvim";
          version = "flake";
          src = inputs.mini-nvim;
        };
      in {
        enable = true;
        aliases = ["vim" "vi"];
        luaFiles = ["${self}/config/nvim/init.lua"];
        plugins = {
          start = with pkgs.vimPlugins; [
            lz-n
            mini-nvim-latest
            nvim-treesitter.withAllGrammars
            nvim-treesitter-textobjects
            nvim-treesitter-context
            nvim-ts-context-commentstring
            plenary-nvim
            SchemaStore-nvim
          ];
          opt = with pkgs.vimPlugins; [
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
          dev.config = {
            pure = "${self}/config/nvim";
          };
          # deps that also live in opt — null so single install under /opt
          # (start/ auto-load would defeat lz.n lazy-load)
          startAttrs = {
            nvim-dap = null;
            nvim-lspconfig = null;
            nvim-nio = null;
            promise-async = null;
          };
        };

        extraBinPath = with pkgs; [
          # LSPs
          nil
          lua-language-server
          vscode-langservers-extracted
          yaml-language-server
          tailwindcss-language-server
          vtsls
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
