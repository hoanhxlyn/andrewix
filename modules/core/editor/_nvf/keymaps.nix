{
  L,
  host,
  mini,
  lib,
}: let
  inherit (mini) picks;
  # P: mini action when picks=true, else Snacks.picker equivalent
  P = m: s:
    if picks
    then m
    else s;
  # B: mini.bufremove/bracketed keymap when tabline=true, else bufferline Ex command
  B = key: desc: action: cmd:
    if mini.tabline
    then {
      inherit key desc;
      mode = "n";
      lua = true;
      inherit action;
    }
    else {
      inherit key desc;
      mode = "n";
      action = "<cmd>${cmd}<cr>";
    };
  # Y: yank helper — key, desc, vim.fn.expand pattern
  Y = key: desc: expand: {
    key = L key;
    mode = "n";
    inherit desc;
    lua = true;
    action = ''
      function()
        local path = vim.fn.expand("${expand}")
        if path == "" then
          vim.notify("No file path to yank", vim.log.levels.WARN)
          return
        end
        vim.fn.setreg("+", path)
        vim.notify("Yanked: " .. path, vim.log.levels.INFO)
      end
    '';
  };
in
  [
    {
      key = L "h";
      mode = "n";
      desc = "Open Dashboard";
      lua = true;
      action =
        if mini.starter
        then "MiniStarter.open"
        else "Snacks.dashboard.open";
    }
    {
      key = L "wq";
      mode = "n";
      action = "q";
    }
    {
      key = L "cf";
      mode = [
        "n"
        "v"
      ];
      desc = "Format buffer (Conform)";
      lua = true;
      action = ''
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end
      '';
    }
    {
      key = "<Esc>";
      mode = "n";
      action = "<cmd>nohlsearch<CR>";
    }
    {
      key = "<c-a>";
      mode = "n";
      action = "ggVG";
    }
    {
      key = "p";
      mode = "v";
      action = ''[["_dP]]'';
      lua = true;
    }
    {
      key = "n";
      mode = "n";
      action = "nzzzv";
    }
    {
      key = "<s-n>";
      mode = "n";
      action = "<s-n>zzzv";
    }
  ]
  ++ lib.optionals mini.notify [
    {
      key = L "nd";
      mode = "n";
      action = "MiniNotify.clear";
      lua = true;
      desc = "Notify: Dismiss";
    }
    {
      key = L "nh";
      mode = "n";
      action = "MiniNotify.show_history";
      lua = true;
      desc = "Notify: History";
    }
  ]
  ++ lib.optionals (!mini.notify) [
    {
      key = L "nd";
      mode = "n";
      lua = true;
      desc = "Notify: Dismiss";
      action = "Snacks.notifier.hide";
    }
    {
      key = L "nh";
      mode = "n";
      lua = true;
      desc = "Notify: History";
      action = "Snacks.notifier.show_history";
    }
    {
      key = L "nc";
      mode = "n";
      lua = true;
      desc = "Notify: Clear all";
      action = "Snacks.notifier.hide";
    }
  ]
  # bufferline-only, no mini.tabline equivalent
  ++ lib.optionals (!mini.tabline) [
    {
      key = L "bl";
      mode = "n";
      desc = "Move buffer right";
      action = "<cmd>BufferLineMoveNext<cr>";
    }
    {
      key = L "bh";
      mode = "n";
      desc = "Move buffer left";
      action = "<cmd>BufferLineMovePrev<cr>";
    }
    {
      key = L "bp";
      mode = "n";
      desc = "Toggle pin buffer";
      action = "<cmd>BufferLineTogglePin<cr>";
    }
  ]
  ++ [
    {
      key = L "j";
      mode = [
        "n"
        "x"
        "o"
      ];
      desc = " Start jumping around";
      lua = true;
      action = ''
        function()
          MiniJump2d.start(MiniJump2d.builtin_opts.query)
        end
      '';
    }
    {
      key = L "e";
      mode = "n";
      desc = "Open explore";
      lua = true;
      action =
        if mini.explorer
        then ''
          function()
            local ok = pcall(MiniFiles.open, vim.api.nvim_buf_get_name(0), false)
            if not ok then MiniFiles.open(nil, false) end
          end
        ''
        else ''function() Snacks.picker.explorer() end'';
    }
    {
      key = L "E";
      mode = "n";
      desc = "Open explore (dir)";
      lua = true;
      action = "function() MiniFiles.open(nil, false) end";
    }
    (B "<s-h>" "Prev buffer" ''
      function()
        MiniBracketed.buffer('backward')
      end
    '' "BufferLineCyclePrev")
    (B "<s-l>" "Next buffer" ''
      function()
        MiniBracketed.buffer('forward')
      end
    '' "BufferLineCycleNext")
    {
      key = L "bd";
      mode = "n";
      desc = "Delete buffer";
      lua = true;
      action = ''
        MiniBufremove.wipeout
      '';
    }
    {
      key = L "ba";
      mode = "n";
      desc = "Delete buffer";
      lua = true;
      action = ''
        function()
        	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        		if vim.bo[buf].buflisted then
        			MiniBufremove.delete(buf, true)
        		end
        	end
        end
      '';
    }
    {
      key = L "bw";
      mode = "n";
      desc = "Wipeout closed buffers";
      lua = true;
      action = ''
        function()
          local visible = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            visible[vim.api.nvim_win_get_buf(win)] = true
          end
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buflisted and not visible[buf] then
              MiniBufremove.wipeout(buf, true)
            end
          end
        end
      '';
    }
    (B (L "bo") "Delete other buffers" ''
      function()
        local cur = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buflisted and buf ~= cur then
            MiniBufremove.delete(buf, true)
          end
        end
      end
    '' "BufferLineCloseOthers")
    (B (L "bL") "Delete buffers to the right" ''
      function()
        local cur = vim.fn.bufnr()
        local bufs = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
        local after = false
        for _, b in ipairs(bufs) do
          if after then MiniBufremove.delete(b, true)
          elseif b == cur then after = true end
        end
      end
    '' "BufferLineCloseRight")
    (B (L "bH") "Delete buffers to the left" ''
      function()
        local cur = vim.fn.bufnr()
        local bufs = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
        for _, b in ipairs(bufs) do
          if b == cur then break end
          MiniBufremove.delete(b, true)
        end
      end
    '' "BufferLineCloseLeft")
    {
      mode = "n";
      key = L "tn";
      desc = "Terminal: New";
      lua = true;
      action = ''
        function()
          Snacks.terminal.open(nil, {
            count = get_next_id(),
          })
        end
      '';
    }
    {
      mode = "n";
      key = L "tf";
      desc = "Terminal: Float";
      lua = true;
      action = ''
        function()
          Snacks.terminal.open(nil, {
            count = get_next_id(),
            win = {
              style = "float",
              enter = true,
              width = 0.7,
              border = "rounded",
              title = "Float Terminal",
              title_pos = "center",
            },
          })
        end
      '';
    }
    {
      mode = "n";
      key = L "tb";
      desc = "Terminal: Btop";
      lua = true;
      action = ''
        function()
          Snacks.terminal.open("btop", { win = { style = "float", enter = true } })
        end
      '';
    }
    {
      mode = "n";
      key = L "td";
      desc = "Terminal: Destroy";
      lua = true;
      action = ''
        function()
          local terms = get_terms()
          if #terms == 0 then
            vim.notify("No terminals to destroy", vim.log.levels.WARN)
            return
          end
          if #terms == 1 then
            kill_term(terms[1].term)
          else
            vim.ui.select(terms, {
              prompt = "Select terminal to destroy:",
              format_item = function(item)
                return "Terminal " .. item.id
              end,
            }, function(choice)
              if choice then kill_term(choice.term) end
            end)
          end
        end
      '';
    }
    {
      mode = "n";
      key = L "tt";
      desc = "Terminal: Toggle";
      lua = true;
      action = ''
        function()
          for _, item in ipairs(get_terms()) do
            item.term:toggle()
          end
        end
      '';
    }
    {
      mode = "n";
      key = L "tx";
      desc = "Terminal: Kill All";
      lua = true;
      action = ''
        function()
          for _, item in ipairs(get_terms()) do
            kill_term(item.term)
          end
        end
      '';
    }
    {
      mode = "n";
      key = L "tl";
      desc = "Terminal: List";
      lua = true;
      action = ''
        function()
          local terms = get_terms()
          if #terms == 0 then
            vim.notify("No terminals found", vim.log.levels.WARN)
            return
          end
          vim.ui.select(terms, {
            prompt = "Select terminal:",
            format_item = function(item)
              return "Terminal " .. item.id
            end,
          }, function(choice)
            if choice then choice.term:toggle() end
          end)
        end
      '';
    }
    {
      mode = "n";
      key = L "gg";
      desc = "Open Lazygit";
      lua = true;
      action = ''
        function()
          Snacks.lazygit.open({ win = { enter = true } })
        end
      '';
    }
    (Y "yf" "Yank full path" "%:p")
    (Y "yr" "Yank relative path" "%")
    (Y "yd" "Yank directory" "%:p:h")
    (Y "yn" "Yank filename" "%:t")
    {
      key = L "ff";
      mode = "n";
      desc = "Find files";
      lua = true;
      action = P "MiniPick.builtin.files" "Snacks.picker.files";
    }
    {
      key = L "fw";
      mode = [
        "n"
        "v"
      ];
      desc = "Find word (Grep)";
      lua = true;
      action =
        if picks
        then ''
          function()
            local getMode = vim.api.nvim_get_mode().mode
            if getMode == "v" then
              MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
            elseif getMode == "n" then
              MiniPick.builtin.grep_live()
            end
          end
        ''
        else ''
          function()
            local getMode = vim.api.nvim_get_mode().mode
            if getMode == "v" then
              Snacks.picker.grep_word()
            else
              Snacks.picker.grep()
            end
          end
        '';
    }
    {
      key = L "fb";
      mode = "n";
      desc = "Find buffers";
      lua = true;
      action = P "MiniPick.builtin.buffers" "Snacks.picker.buffers";
    }
    {
      key = L "fh";
      mode = "n";
      desc = "Find help";
      lua = true;
      action = P "MiniPick.builtin.help" "Snacks.picker.help";
    }
    {
      key = L "fR";
      mode = "n";
      desc = "Find resume";
      lua = true;
      action = P "MiniPick.builtin.resume" "Snacks.picker.resume";
    }
    {
      key = L "fr";
      mode = "n";
      desc = "Find registers";
      lua = true;
      action = P "MiniExtra.pickers.registers" "Snacks.picker.registers";
    }
    {
      key = L "fc";
      mode = "n";
      desc = "Find commands";
      lua = true;
      action = P "MiniExtra.pickers.commands" "Snacks.picker.commands";
    }
    {
      key = L "fk";
      mode = "n";
      desc = "Find keymaps";
      lua = true;
      action = P "MiniExtra.pickers.keymaps" "Snacks.picker.keymaps";
    }
    {
      key = L "fm";
      mode = "n";
      desc = "Find marks";
      lua = true;
      action = P "MiniExtra.pickers.marks" "Snacks.picker.marks";
    }
    {
      key = L "fH";
      mode = "n";
      desc = "Find history";
      lua = true;
      action = P "MiniExtra.pickers.history" "Snacks.picker.command_history";
    }
    {
      key = L "fv";
      mode = "n";
      desc = "Find visit paths";
      lua = true;
      action = P "MiniExtra.pickers.visit_paths" "Snacks.picker.recent";
    }
    {
      key = L "fq";
      mode = "n";
      desc = "Find quickfix";
      lua = true;
      action = P ''function() MiniExtra.pickers.list({ scope = "quickfix" }) end'' "Snacks.picker.qflist";
    }
    {
      key = L "fl";
      mode = "n";
      desc = "Find buffer lines";
      lua = true;
      action = P ''function() MiniExtra.pickers.buf_lines({ scope = "current" }) end'' "Snacks.picker.lines";
    }
    {
      key = L "cd";
      mode = "n";
      desc = "Diagnostic float";
      lua = true;
      action = ''function() vim.diagnostic.open_float() end'';
    }
    {
      key = L "fd";
      mode = "n";
      desc = "Find diagnostics (buffer)";
      lua = true;
      action = P ''function() MiniExtra.pickers.diagnostic(nil, { scope = "current" }) end'' "Snacks.picker.diagnostics_buffer";
    }
    {
      key = L "fD";
      mode = "n";
      desc = "Find diagnostics (all)";
      lua = true;
      action = P ''function() MiniExtra.pickers.diagnostic(nil, { scope = "all" }) end'' "Snacks.picker.diagnostics";
    }
    {
      key = L "ft";
      mode = "n";
      desc = "Find colorschemes";
      lua = true;
      action = P "function() MiniExtra.pickers.colorschemes() end" "Snacks.picker.colorschemes";
    }
    {
      key = L "fT";
      mode = "n";
      desc = "Find task comments";
      lua = true;
      action =
        if picks
        then ''
          function()
            MiniExtra.pickers.hipatterns({
              scope = "all",
              highlighters = { "todo", "fixme", "note", "bug" },
            })
          end
        ''
        else ''function() Snacks.picker.todo_comments() end'';
    }
    {
      key = L "fC";
      mode = "n";
      desc = "Find config files";
      lua = true;
      action =
        if picks
        then ''
          function()
            MiniPick.builtin.files({ tool = "fd" }, { source = { cwd = vim.fn.stdpath("config") } })
          end
        ''
        else ''function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end'';
    }
    {
      key = L "fp";
      mode = "n";
      desc = "Find projects";
      lua = true;
      action =
        if picks
        then ''
          function()
            local project_dir = vim.fs.joinpath(vim.fn.expand("~"), "projects")
            if vim.fn.isdirectory(project_dir) == 0 then return end
            local projects = {}
            for file in vim.fs.dir(project_dir) do
              local path = vim.fs.joinpath(project_dir, file)
              if vim.fn.isdirectory(path) == 1 then table.insert(projects, path) end
            end
            if #projects == 0 then return end
            MiniPick.start({
              source = {
                items = projects,
                name = "Projects",
                show = function(buf_id, items, query)
                  MiniPick.default_show(buf_id, items, query, { show_icons = true })
                end,
              },
            })
          end
        ''
        else ''function() Snacks.picker.projects({ dev = { vim.fs.joinpath(vim.fn.expand("~"), "projects") } }) end'';
    }
    {
      key = L "lr";
      mode = "n";
      desc = "LSP references";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "references" }) end'' "Snacks.picker.lsp_references";
    }
    {
      key = L "ld";
      mode = "n";
      desc = "LSP definitions";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "definition" }) end'' "Snacks.picker.lsp_definitions";
    }
    {
      key = L "lt";
      mode = "n";
      desc = "LSP type definitions";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end'' "Snacks.picker.lsp_type_definitions";
    }
    {
      key = L "li";
      mode = "n";
      desc = "LSP implementations";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "implementation" }) end'' "Snacks.picker.lsp_implementations";
    }
    {
      key = L "lD";
      mode = "n";
      desc = "LSP declarations";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "declaration" }) end'' "Snacks.picker.lsp_declarations";
    }
    {
      key = L "ls";
      mode = "n";
      desc = "LSP symbols";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end'' "Snacks.picker.lsp_symbols";
    }
    {
      key = L "lS";
      mode = "n";
      desc = "LSP workspace symbols";
      lua = true;
      action = P ''function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end'' "Snacks.picker.lsp_workspace_symbols";
    }
    {
      key = L "gb";
      mode = "n";
      desc = "Git: toggle blame";
      lua = true;
      action = ''toggle_blame'';
    }
    {
      key = L "gd";
      mode = "n";
      desc = "Git: diff against commit";
      lua = true;
      action = ''diff_this'';
    }
    {
      key = L "gh";
      mode = "n";
      desc = "Git: toggle overlay";
      lua = true;
      action = ''require("mini.diff").toggle_overlay'';
    }
    {
      key = L "gt";
      mode = "n";
      desc = "Git: toggle diff style";
      lua = true;
      action = ''toggle_diff_style'';
    }
    {
      key = L "gC";
      mode = "n";
      desc = "Git: commit current buffer";
      lua = true;
      action = P ''function() require("mini.extra").pickers.git_commits({ path = vim.api.nvim_buf_get_name(0) }) end'' ''function() Snacks.picker.git_log_file() end'';
    }
    {
      key = L "co";
      mode = "n";
      desc = "Organize imports";
      lua = true;
      action = ''
        function()
          vim.lsp.buf.code_action({
            apply = true,
            context = { only = { "source.organizeImports" }, diagnostics = {} },
          })
        end
      '';
    }
    {
      key = "zO";
      mode = "n";
      desc = "Open all folds";
      lua = true;
      action = ''require("ufo").openAllFolds'';
    }
    {
      key = "zC";
      mode = "n";
      desc = "Close all folds";
      lua = true;
      action = ''require("ufo").closeAllFolds'';
    }
    {
      key = "zi";
      mode = "n";
      desc = "Inspect fold";
      lua = true;
      action = ''require("ufo").inspect'';
    }
    {
      key = "zk";
      mode = "n";
      desc = "Peek folded lines";
      lua = true;
      action = ''require("ufo").peekFoldedLinesUnderCursor'';
    }
    {
      key = "]t";
      mode = "n";
      desc = "Next tab";
      action = "tabnext";
    }
    {
      key = "[t";
      mode = "n";
      desc = "Previous tab";
      action = "tabprevious";
    }
    {
      key = L "ob";
      mode = "n";
      desc = "Open in browser";
      lua = true;
      action = ''
        function()
          local path = vim.fn.expand("%:p")
          if path == "" then
            vim.notify("No file to open", vim.log.levels.WARN)
            return
          end
          vim.fn.jobstart({"xdg-open", path})
        end
      '';
    }
    {
      key = L "on";
      mode = "n";
      desc = "Reveal in Yazi";
      lua = true;
      action = ''
        function()
          local path = vim.fn.expand("%:p")
          if path == "" then
            vim.notify("No file path", vim.log.levels.WARN)
            return
          end
          vim.fn.jobstart({"${host.terminal.name}", "-e", "yazi", path})
        end
      '';
    }
    {
      key = L "mp";
      mode = "n";
      desc = "Markview: toggle";
      action = "<cmd>Markview toggle<cr>";
    }
  ]
