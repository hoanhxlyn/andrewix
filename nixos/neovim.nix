{ pkgs, ... }@inputs:
let
in
{
  programs.nvf = {
    enable = true;
    settings = {
      vim.vimAlias = true;
      vim.lazy.enable = true;
      vim.clipboard.enable = true;
      vim.clipboard.providers.wl-copy.enable = true;
      vim.syntaxHighlighting = true;
      vim.globals = {
        mapleader = " ";
        maplocalleader = "/";
      };
      vim.options = {
        mouse = "a";
        shiftwidth = 2;
        signcolumn = "yes";
        tabstop = 2;
        scrolloff = 3;
        wrap = false;
        breakindent = false;
        laststatus = 2;
        confirm = true;
        foldlevel = 99;
        foldlevelstart = 99;
      };
      vim.keymaps = [
        {
          key = "<leader>e";
          mode = "n";
          silent = true;
          desc = "Open MiniFiles";
          lua = true;
          action = builtins.readFile ../utils/explorer.lua;
        }
        {
          key = "<leader>cf";
          mode = "n";
          silent = true;
          desc = "Format buffer (conform)";
          lua = true;
          action = "require('conform').format";
        }
      ];

      vim.theme = {
        enable = true;
        name = "tokyonight";
        style = "night";
        transparent = true;
      };

      vim.diagnostics = {
        enable = true;
        nvim-lint.enable = true;
        nvim-lint.lint_after_save = true;
      };
      vim.formatter = {
        conform-nvim.enable = true;
        conform-nvim.setupOpts = {
          timeout_ms = 1000;
          lsp_format = "fallback";
          stop_after_first = true;
          formater = {
            biome.require_cwd = true;
          };
        };
      };
      vim.treesitter.textobjects.enable = true;
      vim.treesitter.context.enable = true;

      vim.lsp = {
        formatOnSave = true;
        lspconfig.enable = true;
      };

      vim.languages.ts = {
        enable = true;
        format.enable = true;
        format.type = [
          "biome"
          "prettierd"
        ];
        lsp.enable = true;
        lsp.servers = [ "ts_ls" ];
        treesitter.enable = true;
        extensions.ts-error-translator.enable = true;
      };

      vim.languages.nix = {
        enable = true;
        format.enable = true;
        format.type = [ "nixfmt" ];
        lsp.enable = true;
        lsp.servers = [ "nixd" ];
        treesitter.enable = true;
      };
      vim.ui = {
        nvim-ufo = {
          enable = true;
        };
        borders.enable = true;
        borders.globalStyle = "rounded";
        breadcrumbs.enable = true;
        breadcrumbs.lualine.winbar.enable = true;
        breadcrumbs.lualine.winbar.alwaysRender = true;
      };
      vim.mini = {
        basics.enable = true;
        extra.enable = true;
        files.enable = true;
        ai.enable = true;
        icons.enable = true;
        clue.enable = true;
        surround.enable = true;
        trailspace.enable = true;
        starter.enable = true;

        basics.setupOpts = {
          options = {
            basic = false;
            extra_ui = false;
            win_border = "auto";
          };
          mappings = {
            basics = true;
            windows = true;
            move_with_alt = true;
          };
        };
        files.setupOpts = {
          windows = {
            preview = true;
            width_focus = 30;
            width_preview = 30;
          };
          mappings = {
            go_out_plus = "h";
            synchronize = "<c-s>";
            show_help = "?";
          };

        };
        ai.setupOpts = {
          n_lines = 500;
          L = {
            __raw = "require('mini.extra').gen_ai_spec.line()";
          };
          f = {
            __raw = "require('mini.ai').gen_spec.function_call({ name_pattern = '[%w_]' })";
          };
          F = {
            __raw = "require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' })";
          };
          o = {
            __raw = ''
              require('mini.ai').gen_spec.treesitter({
                a = { "@block.outer", "@loop.outer", "@conditional.outer" },
                i = { "@block.inner", "@loop.inner", "@conditional.inner" },
              })
            '';
          };
          B = {
            __raw = "require('mini.extra').gen_ai_spec.buffer()";
          };
          D = {
            __raw = "require('mini.extra').gen_ai_spec.diagnostic()";
          };
          I = {
            __raw = "require('mini.extra').gen_ai_spec.indent()";
          };
          u = {
            __raw = "require('mini.ai').gen_spec.function_call()";
          };
          U = {
            __raw = "require('mini.ai').gen_spec.function_call({ name_pattern = '[%w_]' })";
          };
          N = {
            __raw = "require('mini.extra').gen_ai_spec.number()";
          };
        };
        clue.setupOpts = {
          window = {
            config = {
              width = "auto";
              anchor = "SW";
              row = "auto";
              col = "auto";
            };
          };
        };
      };
    };
  };
}
