{lib}: {
  autocmds = [
    {
      event = ["FileType"];
      pattern = ["json"];
      callback = lib.generators.mkLuaInline ''function() vim.bo.commentstring = "// %s" end '';
    }
    {
      event = ["User"];
      pattern = ["MiniStarterOpened"];
      callback = lib.generators.mkLuaInline ''
        function()
          local MiniStarter = require("mini.starter");
          if vim.bo.filetype == "ministarter" then
            local opts = { silent = true, buffer = true }
            vim.keymap.set({ "n" }, "j", function ()
              MiniStarter.update_current_item("next")
            end, opts)
            vim.keymap.set({ "n" }, "k", function ()
              MiniStarter.update_current_item("prev")
            end, opts)
          end
        end
      '';
    }
    {
      event = ["CursorMoved"];
      callback = lib.generators.mkLuaInline ''
        function()
          local curword = vim.fn.expand("<cword>")
          local filetype = vim.bo.filetype
          local blocklist = {}
          if filetype == "lua" then
            blocklist = { "local", "require" }
          elseif filetype == "javascript" then
            blocklist = { "import" }
          end
          vim.b.minicursorword_disable = vim.tbl_contains(blocklist, curword)
        end
      '';
      desc = "MiniCursorword blocklist";
    }
    {
      event = ["BufWritePost"];
      callback = lib.generators.mkLuaInline ''
        function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          if path ~= "" then
            path = vim.fn.fnamemodify(path, ":~:.")
          end
          vim.notify("Saved " .. vim.inspect(path))
        end
      '';
      desc = "MiniNotify Saved";
    }
    {
      event = ["User"];
      pattern = ["MiniFilesBufferCreate"];
      callback = lib.generators.mkLuaInline ''
        function(args)
          local buf_id = args.buf
          local MiniFiles = require("mini.files")
          local function map_split(lhs, direction, close_on_file)
            local rhs = function()
              local new_target_window
              local cur_target_window = MiniFiles.get_explorer_state().target_window
              if cur_target_window ~= nil then
                vim.api.nvim_win_call(cur_target_window, function()
                  vim.cmd("belowright " .. direction .. " split")
                  new_target_window = vim.api.nvim_get_current_win()
                end)
                MiniFiles.set_target_window(new_target_window)
                MiniFiles.go_in({ close_on_file = close_on_file })
              end
            end
            local desc = "Open in " .. direction .. " split"
            if close_on_file then
              desc = desc .. " and close"
            end
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
          end
          vim.keymap.set("n", ".", function()
            vim.g.mini_show_dotfiles = not vim.g.mini_show_dotfiles
            MiniFiles.refresh({
              content = {
                filter = function(fs_entry)
                  if vim.g.mini_show_dotfiles then return true end
                  return not vim.startswith(fs_entry.name, ".")
                end,
              },
            })
          end, { buffer = buf_id, desc = "Toggle hidden files" })
          map_split("<c-w>s", "horizontal", false)
          map_split("<c-w>v", "vertical", false)
        end
      '';
    }
    {
      event = ["User"];
      pattern = ["MiniFilesActionRename"];
      callback = lib.generators.mkLuaInline ''
        function(event)
          local Snacks = require("snacks.rename")
          if Snacks then
            Snacks.on_rename_file(event.data.from, event.data.to)
          end
        end
      '';
    }
  ];
  augroups = [
    {
      name = "MiniStarterJK";
      clear = true;
    }
  ];
}
