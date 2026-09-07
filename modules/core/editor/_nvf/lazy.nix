{
  pkgs,
  L,
}: let
  inherit
    (pkgs.vimPlugins)
    sidekick-nvim
    nvim-navic
    mini-sessions
    mini-keymap
    nvim-ts-context-commentstring
    diffview-nvim
    SchemaStore-nvim
    ;
in {
  enable = true;
  plugins = {
    ${sidekick-nvim.pname} = {
      package = sidekick-nvim;
      setupModule = "sidekick";
      setupOpts = {
        nes.enable = false;
        cli.win.layout = "right";
        cli.win.split.width = 80;
      };
      keys = [
        {
          mode = "n";
          key = L "aa";
          desc = "Agent: toggle";
          action = ''
            function()
              require("sidekick.cli").toggle({ filter = {installed = true} })
            end
          '';
          lua = true;
        }
        {
          mode = ["x"];
          key = L "as";
          desc = "Agent: send selection";
          action = ''
            function()
              require("sidekick.cli").send({msg = "{this}", filter = { installed = true } })
            end
          '';
          lua = true;
        }
        {
          mode = "n";
          key = L "af";
          desc = "Agent: Send File";
          action = ''
            function()
              require("sidekick.cli").send({ msg = "{file}", filter = { installed = true } })
            end
          '';
          lua = true;
        }
      ];
    };
    ${nvim-navic.pname} = {
      package = nvim-navic;
      setupModule = "nvim-navic";
      lazy = true;
      event = ["LspAttach"];
      setupOpts = {
        highlight = true;
        depth_limit = 4;
        lsp.auto_attach = true;
      };
      after = ''
        vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}";
      '';
    };
    ${mini-sessions.pname} = {
      package = mini-sessions;
      after = ''
        vim.keymap.set("n", "<leader>ss", function()
          local default_sessions = "session-" .. os.date("%Y%m%d-%H%M%S")
          vim.ui.input({ prompt = "Enter session name: ", default = default_sessions }, function(input)
            if input == nil or input == "" then
              vim.notify("Name is required for session", vim.log.levels.WARN)
              return
            end
            require("mini.sessions").write(input)
            vim.notify("Session " .. input .. " saved", vim.log.levels.INFO)
          end)
        end, { desc = "Save session" })
        vim.keymap.set("n", "<leader>sd", function()
          pcall(require("mini.sessions").select, "delete")
        end, { desc = "Delete session" })
        vim.keymap.set("n", "<leader>sl", function()
          require("mini.sessions").select()
        end, { desc = "Load session" })
        vim.api.nvim_create_autocmd("VimLeavePre", {
          callback = function()
            local except = {"ministarter", "snacks_dashboard"}
            if vim.tbl_contains(except, vim.bo.ft) then
              return
            end
            local default_session = "session-" .. os.date("%Y%m%d-%H%M%S")
            local session_name = require("mini.sessions").get_latest() or default_session
            require("mini.sessions").write(session_name)
          end,
        })
      '';
    };
    ${mini-keymap.pname} = {
      package = mini-keymap;
      after = ''
        local MiniKeymap = require('mini.keymap')
        local map_combo = MiniKeymap.map_combo
        local map_multistep = MiniKeymap.map_multistep
        local mode = { "i", "t", "c", "s", "x" }
        map_combo(mode, "jk", "<bs><bs><esc>")
        map_combo(mode, "kj", "<bs><bs><esc>")
        map_combo(mode, "qq", "<bs><bs><c-\\><c-n>")
        map_combo(mode, "qk", "<bs><bs><c-\\><c-n>")
        map_multistep("i", "<cr>", {"pmenu_accept", "minipairs_cr"})
      '';
    };
    ${nvim-ts-context-commentstring.pname} = {
      package = nvim-ts-context-commentstring;
      lazy = true;
      setupOpts = {
        enable_autocmd = false;
      };
    };
    ${diffview-nvim.pname} = {
      package = diffview-nvim;
      keys = [
        {
          mode = "n";
          key = L "gv";
          desc = "Git: diffview open";
          action = "<cmd>DiffviewOpen<cr>";
        }
        {
          mode = "n";
          key = L "gV";
          desc = "Git: file history";
          action = "<cmd>DiffviewFileHistory %<cr>";
        }
        {
          mode = "n";
          key = L "gx";
          desc = "Git: close diffview";
          action = "<cmd>DiffviewClose<cr>";
        }
      ];
    };
    ${SchemaStore-nvim.pname} = {
      package = SchemaStore-nvim;
    };
  };
}
