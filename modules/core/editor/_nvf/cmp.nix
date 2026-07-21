{lib}: {
  enable = true;
  friendly-snippets.enable = true;
  setupOpts = {
    keymap.preset = "enter";
    cmdline = {
      keymap.preset = "cmdline";
      completion.list.selection.preselect = false;
      completion.menu.auto_show = lib.mkLuaInline ''
        function()
          return vim.fn.getcmdtype() == ":"
        end
      '';
    };
    appearance.nerd_font_variant = "normal";
    completion = {
      accept.auto_brackets.enabled = false;
      documentation.auto_show = false;
      ghost_text.enabled = false;
      menu.draw = {
        columns = lib.mkLuaInline ''
          {
            { "label", gap = 1 },
            { "kind_icon", "kind", "label_description", gap = 1 },
          }
        '';
        treesitter = ["lsp"];
        components = {
          kind_icon = {
            text = lib.mkLuaInline ''
              function(ctx)
                local kind_icon, _, _ = require('mini.icons').get("lsp", ctx.kind)
                return kind_icon
              end
            '';
            highlight = lib.mkLuaInline ''
              function(ctx)
                local _, hl, _ = require('mini.icons').get("lsp", ctx.kind)
                return hl
              end
            '';
          };
          kind = {
            highlight = lib.mkLuaInline ''
               function(ctx)
                local _, hl, _ = require('mini.icons').get("lsp", ctx.kind)
                return hl
              end
            '';
          };
        };
      };
    };
    signature = {
      enabled = true;
      window.show_documentation = false;
    };
  };
  sourcePlugins = {
    lazydev = {
      enable = true;
      package = "lazydev-nvim";
      module = "lazydev.integrations.blink";
    };
    emoji.enable = false;
    ripgrep.enable = false;
    spell.enable = true;
  };
}
