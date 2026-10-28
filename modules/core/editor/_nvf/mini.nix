{
  lib,
  mini,
  self,
  leaderGroups,
}: {
  ai.enable = true;
  ai.setupOpts.custom_textobjects = {
    L = lib.generators.mkLuaInline "require('mini.extra').gen_ai_spec.line()";
    f = lib.generators.mkLuaInline ''require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" })'';
    F = lib.generators.mkLuaInline ''require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" })'';
    o = lib.generators.mkLuaInline ''require("mini.ai").gen_spec.treesitter({ a = { "@block.outer", "@loop.outer", "@conditional.outer" }, i = { "@block.inner", "@loop.inner", "@conditional.inner" } })'';
    B = lib.generators.mkLuaInline "require('mini.extra').gen_ai_spec.buffer()";
    D = lib.generators.mkLuaInline "require('mini.extra').gen_ai_spec.diagnostic()";
    I = lib.generators.mkLuaInline "require('mini.extra').gen_ai_spec.indent()";
    u = lib.generators.mkLuaInline ''require("mini.ai").gen_spec.function_call()'';
    U = lib.generators.mkLuaInline ''require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" })'';
    N = lib.generators.mkLuaInline "require('mini.extra').gen_ai_spec.number()";
  };
  git.enable = true;
  diff.enable = true;
  diff.setupOpts.view.style = "number";
  diff.setupOpts.view.signs.add = "▎";
  diff.setupOpts.view.signs.change = "▎";
  diff.setupOpts.view.signs.delete = "";
  diff.setupOpts.mappings = {
    reset = "<leader>gr";
    textobject = "gh";
    goto_first = "[H";
    goto_last = "]H";
    goto_next = "]h";
    goto_prev = "[h";
  };
  misc.enable = true;
  move.enable = true;
  pick.enable = mini.picks;
  pick.setupOpts.options.content_from_bottom = false;
  pick.setupOpts.options.use_cache = true;
  pick.setupOpts.window.config = lib.generators.mkLuaInline ''
    function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = "NW",
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end
  '';
  pick.setupOpts.mappings = {
    toggle_preview = "<c-k>";
    toggle_info = "?";
    refine = "<c-q>";
    move_start = "";
    choose_marked = "<c-g>";
  };
  files.enable = mini.explorer;
  files.setupOpts.content.filter = lib.generators.mkLuaInline ''
    function(fs_entry)
      if vim.g.mini_show_dotfiles then return true end
      return not vim.startswith(fs_entry.name, ".")
    end
  '';
  files.setupOpts.windows.preview = true;
  files.setupOpts.windows.width_focus = 30;
  files.setupOpts.windows.width_preview = 30;
  files.setupOpts.mappings.go_out_plus = "h";
  files.setupOpts.mappings.synchronize = "<c-s>";
  files.setupOpts.mappings.show_help = "?";
  extra.enable = true;
  icons.enable = true;
  icons.setupOpts = import "${self}/modules/core/editor/_nvf/mini-icons.nix";
  pairs.enable = true;
  pairs.setupOpts = {
    modes.insert = true;
    modes.command = false;
    modes.terminal = false;
    skip_next = ''[=[%w%%%'%[%]"%.%`%$]=]'';
    skip_unbalanced = true;
    markdown = true;
  };
  basics.enable = true;
  basics.setupOpts.options.basic = false;
  basics.setupOpts.options.extra_ui = false;
  basics.setupOpts.mappings.basic = true;
  basics.setupOpts.mappings.windows = true;
  basics.setupOpts.mappings.move_with_alt = true;
  comment.enable = true;
  comment.setupOpts.options.custom_commentstring = lib.generators.mkLuaInline ''
    function()
      return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
    end
  '';
  starter.enable = mini.starter;
  starter.setupOpts = {
    evaluate_single = true;
    header = builtins.readFile "${self}/config/arts/andrewix.txt";
    items = lib.generators.mkLuaInline ''
      {
        require("mini.starter").sections.sessions(3),
        require("mini.starter").sections.recent_files(3, true, false),
        ${lib.optionalString mini.picks ''require("mini.starter").sections.pick(),''}
        require("mini.starter").sections.builtin_actions(),
      }
    '';
    footer = "⚡ Nvf andrewix";
  };
  sessions.enable = true;
  sessions.setupOpts = {
    autoread = false;
    autowrite = true;
    force.delete = true;
    force.write = true;
    directory = lib.generators.mkLuaInline ''
      vim.fn.stdpath("data") .. "/sessions/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    '';
  };
  snippets.enable = true;
  snippets.setupOpts.mappings.expand = "<c-j>";
  surround.enable = true;
  surround.setupOpts.mappings = {
    add = "sa";
    delete = "sd";
    find = "sf";
    find_left = "sF";
    highlight = "sh";
    replace = "sr";
    update_n_lines = "sn";
  };
  surround.setupOpts.search_method = "cover_or_nearest";
  bracketed.enable = true;
  bracketed.setupOpts.treesitter.suffix = "s";
  bufremove.enable = true;
  operators.enable = true;
  operators.setupOpts = {
    evaluate = {};
    exchanges.prefix = "<Leader>ox";
    multiply.prefix = "<Leader>om";
    replace.prefix = "<Leader>or";
    sort = {};
  };
  cursorword.enable = true;
  hipatterns.enable = true;
  hipatterns.setupOpts = {
    highlighters =
      # words highlighted by folke/todo-comments when picks=false (see nvf.nix notes.todo-comments)
      lib.optionalAttrs mini.picks {
        fixme = lib.generators.mkLuaInline ''
          require("mini.extra").gen_highlighter.words({ "FIXME", "fixme" }, "MiniHiPatternsFixme")
        '';
        todo = lib.generators.mkLuaInline ''
          require("mini.extra").gen_highlighter.words({ "TODO", "todo" }, "MiniHiPatternsTodo")
        '';
        note = lib.generators.mkLuaInline ''
          require("mini.extra").gen_highlighter.words({ "NOTE", "note", "readme", "README" }, "MiniHiPatternsNote")
        '';
        bug = lib.generators.mkLuaInline ''
          require("mini.extra").gen_highlighter.words({ "BUG", "bug", "HACK", "hack", "hax" }, "MiniHiPatternsHack")
        '';
      }
      // {
        hex_color = lib.generators.mkLuaInline ''
          require("mini.hipatterns").gen_highlighter.hex_color({ priority = 200 })
        '';
        hex_shorthand.pattern = "()#%x%x%x()%f[^%x%w]";
        hex_shorthand.group = lib.generators.mkLuaInline ''
          function(_, _, data)
            local match = data.full_match
            local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
            local hex_color = "#" .. r .. r .. g .. g .. b .. b
            return require("mini.hipatterns").compute_hex_color_group(hex_color, "bg")
          end
        '';
      };
  };
  statusline.enable = mini.statusline;
  statusline.setupOpts.content.active = lib.generators.mkLuaInline ''
    function()
      local MiniStatusline = require("mini.statusline")
      local MiniIcons = require("mini.icons")

      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 75 })
      mode = mode:upper()

      local recording = ""
      local reg = vim.fn.reg_recording()
      if reg ~= "" then
        recording = "Recording @" .. reg
      end

      local git = MiniStatusline.section_git({ icon = "󰘬", trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ icon = "", trunc_width = 100 })
      local diagnostics = MiniStatusline.section_diagnostics({
        icon = "",
        signs = {
          ERROR = "󰅙 ",
          WARN = "󰀦 ",
          INFO = "󱈸 ",
          HINT = "󰌵 ",
        },
        trunc_width = 75,
      })
      local lsp = MiniStatusline.section_lsp({ icon = "󰆦", trunc_width = 75 })

      local copilot = ""
      if vim.fn.exists("*copilot#Enabled") == 1 and vim.fn["copilot#Enabled"]() == 1 then
        copilot = " "
      end

      local filetype = vim.bo.filetype
      local ft_icon = MiniIcons.get("filetype", filetype)
      filetype = ft_icon .. " " .. filetype

      local fileinfo = filetype
      if not MiniStatusline.is_truncated(150) and vim.bo.buftype == "" then
        local encoding = vim.bo.fileencoding or vim.bo.encoding
        local size = math.max(vim.fn.line2byte(vim.fn.line("$") + 1) - 1, 0)
        local size_str
        if size < 1024 then
          size_str = string.format("%dB", size)
        elseif size < 1048576 then
          size_str = string.format("%.2fKiB", size / 1024)
        else
          size_str = string.format("%.2fMiB", size / 1048576)
        end
        fileinfo = string.format("%s [%s] %s", filetype, encoding, size_str)
      end

      local current_line = vim.api.nvim_win_get_cursor(0)[1]
      local total_lines = vim.api.nvim_buf_line_count(0)
      local location
      if current_line == 1 then
        location = "TOP"
      elseif current_line == total_lines then
        location = "BOTTOM"
      else
        location = "%p%%"
      end

      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
      local filename = vim.fn.expand("%:h:t") .. "/" .. vim.fn.expand("%:t")
      local eol = vim.bo.fileformat == "unix" and " " or " "

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
        "%<",
        { hl = "MiniStatuslineFileName", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = {recording, eol, copilot, lsp, fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      })
    end
  '';
  tabline.enable = mini.tabline;
  tabline.setupOpts.show_icons = true;
  tabline.setupOpts.format = lib.generators.mkLuaInline ''
    function(buf_id, label)
      local buf_name = vim.api.nvim_buf_get_name(buf_id)
      local icon = require("mini.icons").get("file", buf_name)
      local is_edited = vim.bo[buf_id].modified and "󰏫 " or ""
      local hasErrors = vim.diagnostic.get(buf_id, { severity = "ERROR" })
      if #hasErrors > 0 then
        icon = "󰅙 "
      else
        local hasWarnings = vim.diagnostic.get(buf_id, { severity = "WARN" })
        if #hasWarnings > 0 then
          icon = "󰀦 "
        end
      end
      -- ponytail: mini.tabline has no offsets; pad first tab when snacks explorer sidebar is open on the left
      local pad = ""
      local first_buf = nil
      for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if first_buf == nil or b.bufnr < first_buf then
          first_buf = b.bufnr
        end
      end
      if buf_id == first_buf then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
          if ft == "snacks_picker_list" or ft == "snacks_picker_input" then
            local cfg = vim.api.nvim_win_get_config(win)
            local width, is_left = cfg.width or 30, false
            if cfg.relative == "" and cfg.col == 0 then
              is_left = true
            elseif cfg.relative == "win" and cfg.col == 0 and cfg.win then
              is_left = true
              width = vim.api.nvim_win_get_width(cfg.win)
            end
            if is_left then
              pad = string.rep(" ", width)
              break
            end
          end
        end
      end

      return string.format("%s %s %s %s", pad, icon, label, is_edited)
    end
  '';
  notify.enable = mini.notify;
  notify.setupOpts = {
    lsp_progress.enable = true;
    lsp_progress.duration_last = 2000;
    window.config.row = 2;
    content.format = lib.mkLuaInline ''
      function(notif)
       if notif.data.source == "lsp_progress" then
         return notif.msg
       end
       return MiniNotify.default_format(notif)
      end
    '';
    content.sort = lib.mkLuaInline ''
      function(notif_arr)
        table.sort(notif_arr, function(a, b) return a.ts_update > b.ts_update end)
        return notif_arr
      end
    '';
  };
  animate.enable = mini.animate;
  animate.setupOpts = {
    cursor.enable = false;
    scroll.enable = true;
    scroll.timing = lib.mkLuaInline ''require("mini.animate").gen_timing.quadratic({ unit = "total" }); '';
    resize.enable = true;
    open.enable = true;
    close.enable = true;
  };
  trailspace.enable = true;
  indentscope.enable = mini.indent_scope;
  indentscope.setupOpts.options.try_as_border = true;
  indentscope.setupOpts.draw.animation = lib.generators.mkLuaInline ''require("mini.indentscope").gen_animation.quadratic({ easing = "in-out", duration = 200, unit = "total" })'';
  indentscope.setupOpts.ignore_filetypes = [
    "Trouble"
    "alpha"
    "dashboard"
    "fzf"
    "help"
    "lazy"
    "ministarter"
    "neo-tree"
    "notify"
    "sidekick_terminal"
    "snacks_dashboard"
    "snacks_notif"
    "snacks_terminal"
    "snacks_win"
    "toggleterm"
    "trouble"
  ];
  jump.enable = true;
  jump.setupOpts.mappings.forward = "f";
  jump.setupOpts.mappings.backward = "F";
  jump.setupOpts.mappings.repeat_jump = ";";
  jump2d.enable = true;
  jump2d.setupOpts.labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKL";
  jump2d.setupOpts.view.dim = true;
  jump2d.setupOpts.mappings.start_jumping = "<leader>j";
  visits.enable = true;
  clue = lib.optionalAttrs mini.clues {
    enable = true;
    setupOpts.window.config = {
      width = "auto";
      anchor = "SW";
      row = "auto";
      col = "auto";
    };
    setupOpts.clues =
      (map (key: {
        mode =
          if key == "o"
          then ["n" "x" "i"]
          else "n";
        keys = "<leader>${key}";
        desc = "+ ${leaderGroups.${key}}";
      }) (builtins.attrNames leaderGroups))
      ++ [
        (lib.generators.mkLuaInline "require('mini.clue').gen_clues.builtin_completion()")
        (lib.generators.mkLuaInline "require('mini.clue').gen_clues.g()")
        (lib.generators.mkLuaInline "require('mini.clue').gen_clues.marks()")
        (lib.generators.mkLuaInline "require('mini.clue').gen_clues.registers()")
        (lib.generators.mkLuaInline "require('mini.clue').gen_clues.windows({ submode_resize = true })")
        (lib.generators.mkLuaInline "require('mini.clue').gen_clues.z()")
      ];
    setupOpts.triggers =
      (lib.concatMap (m:
        map (keys: {
          mode = m;
          inherit keys;
        }) [
          "<Leader>"
          "\\"
          "["
          "]"
          "g"
          "'"
          "`"
          "z"
        ]) ["n" "x"])
      ++ (map (keys: {
        mode = "n";
        inherit keys;
      }) ["\\"])
      ++ (map (keys: {
        mode = "i";
        inherit keys;
      }) ["<C-x>" "<C-r>"])
      ++ [
        {
          mode = "c";
          keys = "<C-r>";
        }
        {
          mode = "n";
          keys = "<C-w>";
        }
      ];
  };
}
