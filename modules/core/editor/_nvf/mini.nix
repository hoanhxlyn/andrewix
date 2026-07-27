{
  lib,
  mini,
  self,
}: {
  ai = {
    enable = true;
    setupOpts.custom_textobjects = {
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
  };
  git.enable = true;
  diff = {
    enable = true;
    setupOpts = {
      view = {
        style = "number";
        signs = {
          add = "▎";
          change = "▎";
          delete = "";
        };
      };
      mappings = {
        reset = "<leader>gr";
        textobject = "gh";
        goto_first = "[H";
        goto_last = "]H";
        goto_next = "]h";
        goto_prev = "[h";
      };
    };
  };
  misc.enable = true;
  move.enable = true;
  pick = {
    enable = mini.picks;
    setupOpts = {
      options = {
        content_from_bottom = false;
        use_cache = true;
      };
      window.config = lib.generators.mkLuaInline ''
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
      mappings = {
        toggle_preview = "<c-k>";
        toggle_info = "?";
        refine = "<c-q>";
        move_start = "";
        choose_marked = "<c-g>";
      };
    };
  };
  files = {
    enable = mini.explorer;
    setupOpts = {
      content.filter = lib.generators.mkLuaInline ''
        function(fs_entry)
          if vim.g.mini_show_dotfiles then return true end
          return not vim.startswith(fs_entry.name, ".")
        end
      '';
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
  };
  extra.enable = true;
  icons = {
    enable = true;
    setupOpts = import "${self}/modules/core/editor/_nvf/mini-icons.nix";
  };
  pairs = {
    enable = true;
    setupOpts = {
      modes = {
        insert = true;
        command = false;
        terminal = false;
      };
      skip_next = ''[=[%w%%%'%[%]"%.%`%$]=]'';
      skip_unbalanced = true;
      markdown = true;
    };
  };
  basics = {
    enable = true;
    setupOpts = {
      options.basic = false;
      options.extra_ui = false;
      mappings = {
        basic = true;
        windows = true;
        move_with_alt = true;
      };
    };
  };
  comment = {
    enable = true;
    setupOpts = {
      options = {
        custom_commentstring = lib.generators.mkLuaInline ''
          function()
            return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
          end
        '';
      };
    };
  };
  starter = {
    enable = mini.starter;
    setupOpts = {
      evaluate_single = true;
      header = lib.removeSuffix "\n" (builtins.readFile "${self}/config/arts/andrewix.txt");
      items = lib.generators.mkLuaInline ''
        {
          require("mini.starter").sections.sessions(3),
          require("mini.starter").sections.recent_files(3, true, false),
          require("mini.starter").sections.pick(),
          require("mini.starter").sections.builtin_actions(),
        }
      '';
      footer = "⚡ Nvf andrewix";
    };
  };
  sessions = {
    enable = true;
    setupOpts = {
      autoread = false;
      autowrite = true;
      force.delete = true;
      force.write = true;
      directory = lib.generators.mkLuaInline ''
        vim.fn.stdpath("data") .. "/sessions/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      '';
    };
  };
  snippets = {
    enable = true;
    setupOpts = {
      mappings.expand = "<c-j>";
    };
  };
  surround = {
    enable = true;
    setupOpts = {
      mappings = {
        add = "sa";
        delete = "sd";
        find = "sf";
        find_left = "sF";
        highlight = "sh";
        replace = "sr";
        update_n_lines = "sn";
      };
      search_method = "cover_or_nearest";
    };
  };
  bracketed = {
    enable = true;
    setupOpts = {
      treesitter.suffix = "s";
    };
  };
  bufremove.enable = true;
  operators = {
    enable = true;
    setupOpts = {
      evaluate = {};
      exchanges.prefix = "<Leader>ox";
      multiply.prefix = "<Leader>om";
      replace.prefix = "<Leader>or";
      sort = {};
    };
  };
  cursorword.enable = true;
  hipatterns = {
    enable = true;
    setupOpts = {
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
          hex_shorthand = {
            pattern = "()#%x%x%x()%f[^%x%w]";
            group = lib.generators.mkLuaInline ''
              function(_, _, data)
                local match = data.full_match
                local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
                local hex_color = "#" .. r .. r .. g .. g .. b .. b
                return require("mini.hipatterns").compute_hex_color_group(hex_color, "bg")
              end
            '';
          };
        };
    };
  };
  statusline = {
    enable = true;
    setupOpts = {
      content = {
        active = lib.generators.mkLuaInline ''
          function()
            local MiniStatusline = require("mini.statusline")
            local MiniIcons = require("mini.icons")

            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 75 })
            mode = mode:upper()

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
              { hl = "MiniStatuslineFileinfo", strings = { eol, copilot, lsp, fileinfo } },
              { hl = mode_hl, strings = { search, location } },
            })
          end
        '';
      };
    };
  };
  tabline = {
    enable = true;
    setupOpts = {
      show_icons = true;
      format = lib.generators.mkLuaInline ''
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
          return string.format(" %s %s %s", icon, label, is_edited)
        end
      '';
    };
  };
  notify = {
    enable = mini.notify;
    setupOpts = {
      lsp_progress.enable = true;
      lsp_progress.duration_last = 2000;
      window.config.row = 2;
      content = {
        format = lib.mkLuaInline ''
          function(notif)
           if notif.data.source == "lsp_progress" then
             return notif.msg
           end
           return MiniNotify.default_format(notif)
          end
        '';
        sort = lib.mkLuaInline ''
          function(notif_arr)
            table.sort(notif_arr, function(a, b) return a.ts_update > b.ts_update end)
            return notif_arr
          end
        '';
      };
    };
  };
  animate = {
    enable = mini.animate;
    setupOpts = {
      cursor.enable = false;
      scroll = {
        enable = false;
        timing = lib.mkLuaInline ''require("mini.animate").gen_timing.quadratic({ unit = "total" }); '';
      };
      resize.enable = true;
      open.enable = true;
      close.enable = true;
    };
  };
  trailspace.enable = true;
  indentscope = {
    enable = mini.indent_scope;
    setupOpts = {
      options.try_as_border = true;
      draw.animation = lib.generators.mkLuaInline ''require("mini.indentscope").gen_animation.quadratic({ easing = "in-out", duration = 200, unit = "total" })'';
      ignore_filetypes = [
        "Trouble"
        "alpha"
        "dashboard"
        "fzf"
        "help"
        "lazy"
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
    };
  };
  jump = {
    enable = true;
    setupOpts = {
      mappings = {
        forward = "f";
        backward = "F";
        repeat_jump = ";";
      };
    };
  };
  jump2d = {
    enable = true;
    setupOpts = {
      labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKL";
      view.dim = true;
      mappings = {
        start_jumping = "<leader>j";
      };
    };
  };
  visits.enable = true;
  clue = {
    enable = true;
    setupOpts = {
      window.config = {
        width = "auto";
        anchor = "SW";
        row = "auto";
        col = "auto";
      };

      clues =
        (map ({
            keys,
            desc,
          }: {
            mode = "n";
            inherit keys desc;
          }) [
            {
              keys = "<leader>a";
              desc = "+ Agents";
            }
            {
              keys = "<leader>b";
              desc = "+ Buffers";
            }
            {
              keys = "<leader>c";
              desc = "+ Code";
            }
            {
              keys = "<leader>cs";
              desc = "+ Code spell";
            }
            {
              keys = "<leader>d";
              desc = "+ Debugger";
            }
            {
              keys = "<leader>f";
              desc = "+ Find";
            }
            {
              keys = "<leader>g";
              desc = "+ Git";
            }
            {
              keys = "<leader>l";
              desc = "+ Lsp";
            }
            {
              keys = "<leader>n";
              desc = "+ Notify";
            }
            {
              keys = "<leader>s";
              desc = "+ Sessions";
            }
            {
              keys = "<leader>p";
              desc = "+ Package";
            }
            {
              keys = "<leader>t";
              desc = "+ Terminal";
            }
            {
              keys = "<leader>w";
              desc = "+ Window";
            }
            {
              keys = "<leader>y";
              desc = "+ Yank";
            }
          ])
        ++ [
          {
            mode = ["n" "x" "i"];
            keys = "<leader>o";
            desc = "+ Operators";
          }
          (lib.generators.mkLuaInline "require('mini.clue').gen_clues.builtin_completion()")
          (lib.generators.mkLuaInline "require('mini.clue').gen_clues.g()")
          (lib.generators.mkLuaInline "require('mini.clue').gen_clues.marks()")
          (lib.generators.mkLuaInline "require('mini.clue').gen_clues.registers()")
          (lib.generators.mkLuaInline "require('mini.clue').gen_clues.windows({ submode_resize = true })")
          (lib.generators.mkLuaInline "require('mini.clue').gen_clues.z()")
        ];
      triggers =
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
  };
}
