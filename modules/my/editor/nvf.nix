{
  __findFile,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.nvf.url = "github:notashelf/nvf";

  den.aspects.my.editor.nvf = {
    includes = [
      (<den/unfree> ["copilot-language-server"])
    ];

    nixos = {pkgs, ...}: let
      L = key: "<leader>${key}";
      mini = {
        explorer = true;
        picks = true;
        animate = true;
        notify = true;
        indent_scope = true;
        show_dotfiles = true;
      };
    in {
      imports = [inputs.nvf.nixosModules.default];
      programs.nvf = {
        enable = true;
        settings.vim = {
          viAlias = false;
          vimAlias = true;
          syntaxHighlighting = true;
          enableLuaLoader = true; # Speed up startup (experimental)
          lineNumberMode = "relNumber"; # "relative" | "number" | "relNumber"
          searchCase = "smart";
          options = {
            wrap = false;
            shiftwidth = 2;
            tabstop = 2;
            foldcolumn = "auto";
            foldlevel = 99;
            foldlevelstart = 99;
            foldenable = true;
            scrolloff = 3;
            showmode = false;
            formatoptions = "jcroqlnt";
            grepformat = "%f:%l:%c:%m";
            grepprg = "rg; --vimgrep";
          };
          globals = {
            maplocalleader = "\\";
            mini_show_dotfiles = mini.show_dotfiles;
          };
          clipboard = {
            enable = true;
            registers = "unnamedplus";
            providers.wl-copy.enable = true;
          };
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
          extraPackages = with pkgs; [ueberzugpp];
          # LSP config
          lsp = {
            enable = true;
            formatOnSave = true;
            inlayHints.enable = true;
            lspconfig.enable = true;
            mappings = {
              codeAction = L "ca";
              hover = L "lh";
              nextDiagnostic = "]d";
              previousDiagnostic = "[d";
              openDiagnosticFloat = L "cd";
              renameSymbol = L "cr";
              signatureHelp = "<c-/>";
            };
          };
          # Treeesitter modules
          treesitter = {
            enable = true;
            highlight.enable = true;
            indent.enable = true;
            context = {
              enable = true;
              setupOpts = {
                max_lines = 3;
                mode = "topline";
                zindex = 30;
              };
            };
            textobjects.enable = true;
            textobjects.setupOpts = {
              move = {
                enable = true;
                set_jumps = true;
              };
            };
            autotagHtml.enable = true;
          };
          # Conform modules
          formatter.conform-nvim = {
            enable = true;
            setupOpts = {
              notify_on_error = true;
              default_format_opts = {
                timeout_ms = 1000;
                lsp_format = "fallback";
                stop_after_first = true;
              };
              formatters_by_ft = {
                just = ["just"];
              };
              formatters = {
                biome = {require_cwd = true;};
                oxfmt = {
                  command = lib.getExe pkgs.oxfmt;
                  require_cwd = true;
                };
                stylua = {};
                markdown-toc = {
                  condition = lib.generators.mkLuaInline ''
                    function(_, ctx)
                      for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                        if line:find("<!%-%- toc %-%->") then
                          return true
                        end
                      end
                      return false
                    end
                  '';
                };
                markdownlint-cli2 = {
                  condition = lib.generators.mkLuaInline ''
                    function(_, ctx)
                      local diag = vim.tbl_filter(function(d)
                        return d.source == "markdownlint"
                      end, vim.diagnostic.get(ctx.buf))
                      return #diag > 0
                    end
                  '';
                };
              };
            };
          };
          # Diagnostic modules
          diagnostics = {
            enable = true;
            config = {
              severity_sort = true;
              float = {
                borders = "rounded";
                source = "if_many";
              };
              underline = lib.generators.mkLuaInline "{severity = vim.diagnostic.severity.ERROR }";
              signs.text = lib.generators.mkLuaInline ''
                           {
                	[vim.diagnostic.severity.ERROR] = "󰅙 " ,
                	[vim.diagnostic.severity.WARN] = "󰀦 ",
                	[vim.diagnostic.severity.INFO] = "󱈸 ",
                	[vim.diagnostic.severity.HINT] = "󰌵 ",
                } '';
              virtual_text = {
                source = "if_many";
                spacing = 2;
                format = lib.generators.mkLuaInline ''
                  function(diagnostic)
                  return diagnostic.message
                  end
                '';
              };
            };
          };
          # Languague Modules (LSP + TS + etc)
          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableDAP = false;
            enableExtraDiagnostics = true;
            bash.enable = true;
            css.enable = true;
            scss.enable = true;
            css.format.type = [
              "biome"
              "prettierd"
            ];
            scss.format.type = ["prettierd"];
            html.enable = true;
            html.lsp.servers = ["superhtml"];
            jq.enable = true;
            json.enable = true;
            just.enable = true;
            lua = {
              enable = true;
              extraDiagnostics.types = ["selene"];
              lsp.lazydev.enable = true;
            };
            markdown = {
              enable = true;
              extensions.markview-nvim.enable = true;
              lsp.servers = ["markdown-oxide"];
              format.type = ["mdformat"];
            };
            nix.enable = true;
            toml.enable = true;
            typescript.enable = true;
            typescript.extensions.ts-error-translator.enable = true;
            typescript.extraDiagnostics.types = [
              "biomejs"
              "eslint_d"
            ];
            typescript.format.type = [
              "biome"
              "prettierd"
            ];
            typescript.lsp.servers = ["typescript-go"];
            yaml.enable = true;
          };
          # UI modules
          ui = {
            ui2 = {
              enable = true;
              setupOpts = {
                msg = {
                  cmd.height = 1;
                  dialog.height = 1;
                  msg.height = 1;
                };
              };
            };
            borders.enable = true;
            nvim-ufo.enable = true;
          };
          # Utility modules
          utility.snacks-nvim = {
            enable = true;
            setupOpts = {
              statuscolumn = {
                enable = true;
                left = [
                  "git"
                  "mark"
                ];
                right = [
                  "sign"
                  "fold"
                ];
                folds.open = true;
                folds.git_hl = false;
                git.patterns = ["MiniDiffSign"];
              };
              explorer.enabled = !mini.explorer;
              picker = {
                enabled = !mini.picks;
                sources = {
                  explorer = {
                    hidden = mini.show_dotfiles;
                    ignored = mini.show_dotfiles;
                    exclude = [
                      ".git"
                      "node_modules"
                    ];
                  };
                };
              };
              animate.easing = lib.mkIf (!mini.animate) "inOutQuad";
              quickfile.enabled = false;
              scroll.enabled = !mini.animate;
              lazygit.enabled = true;
              terminal.enabled = true;
              terminal.win.enter = false;
              bigfile.enabled = true;
              image.enabled = true;
              input.enabled = true;
              indent.enabled = !mini.indent_scope;
              notify.enabled = !mini.notify;
              notify.style = "compact";
              notify.margin.top = 2;
              styles.notification.wo.wrap = true;
            };
          };
          pluginRC.snacks-terminal-helpers = inputs.nvf.lib.nvim.dag.entryAfter ["snacks-nvim"] ''
            local function get_terms()
              local terms = {}
              for i = 1, 20 do
                local term = Snacks.terminal.get(nil, { count = i, create = false })
                if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
                  table.insert(terms, { id = i, term = term })
                end
              end
              return terms
            end
            _G.get_next_id = function()
              local terms = get_terms()
              local map = {}
              for _, t in ipairs(terms) do map[t.id] = true end
              for i = 1, 20 do
                if not map[i] then return i end
              end
              return #terms + 1
            end
            _G.kill_term = function(term)
              if term.destroy then
                term:destroy()
              else
                term:close()
                if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
                  vim.api.nvim_buf_delete(term.buf, { force = true })
                end
              end
            end
            _G.get_terms = get_terms
          '';
          utility.images.image-nvim.enable = true;

          # Autocomplete modules
          autocomplete.blink-cmp = {
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
                ghost_text.enabled = true;
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
            };
            sourcePlugins = {
              lazydev.enable = true;
              lazydev.package = "lazydev-nvim";
              lazydev.module = "lazydev.integrations.blink";
              emoji.enable = false;
              ripgrep.enable = false;
              spell.enable = true;
            };
          };
          # Mini modules
          mini.ai = {
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
          mini.git.enable = true;
          mini.diff = {
            enable = true;
            setupOpts = {
              view.style = "number";
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
          mini.misc.enable = true;
          mini.move.enable = true;
          mini.pick = {
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
          mini.files = {
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
          mini.extra.enable = true;
          mini.icons.enable = true;
          mini.pairs = {
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
          mini.basics = {
            enable = true;
            setupOpts = {
              options.basic = false;
              options.extra_ui = false;
              mappings.basic = true;
              mappings.windows = true;
              mappings.move_with_alt = true;
            };
          };
          mini.comment = {
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
          mini.starter = {
            enable = true;
            setupOpts = {
              evaluate_single = true;
              header = ''
                   _____              .___                     .__
                  /  _  \   ____    __| _/______   ______  _  _|__|__  ___
                 /  /_\  \ /    \  / __ |\_  __ \_/ __ \ \/ \/ /  \  \/  /
                /    |    \   |  \/ /_/ | |  | \/\  ___/\     /|  |>    <
                \____|__  /___|  /\____ | |__|    \___  >\/\_/ |__/__/\_ \
                        \/     \/      \/             \/                \/
              '';
            };
          };
          mini.sessions = {
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
          mini.snippets = {
            enable = true;
            setupOpts = {
              mappings.expand = "<c-j>";
            };
          };
          mini.surround = {
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
          mini.bracketed.enable = true;
          mini.bufremove.enable = true;
          mini.operators = {
            enable = true;
            setupOpts = {
              evaluate = {};
              exchanges.prefix = "<Leader>ox";
              multiply.prefix = "<Leader>om";
              replace.prefix = "<Leader>or";
              sort = {};
            };
          };
          mini.cursorword.enable = true;
          mini.hipatterns.enable = true;
          mini.statusline.enable = true;
          mini.tabline.enable = true;
          mini.notify = {
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
          mini.animate = {
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
          mini.trailspace.enable = true;
          mini.indentscope = {
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
          mini.jump = {
            enable = true;
            setupOpts = {
              mappings = {
                forward = "f";
                backward = "F";
                repeat_jump = ";";
              };
            };
          };
          mini.jump2d = {
            enable = true;
            setupOpts = {
              labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKL";
              view.dim = true;
              mappings = {
                start_jumping = "<leader>j";
              };
            };
          };
          mini.visits.enable = true;
          mini.clue = {
            enable = true;
            setupOpts = {
              window.config.width = "auto";
              window.config.anchor = "SW";
              window.config.row = "auto";
              window.config.col = "auto";
              clues = [
                {
                  mode = "n";
                  keys = "<leader>a";
                  desc = "+ Agents";
                }
                {
                  mode = "n";
                  keys = "<leader>b";
                  desc = "+ Buffers";
                }
                {
                  mode = "n";
                  keys = "<leader>c";
                  desc = "+ Code";
                }
                {
                  mode = "n";
                  keys = "<leader>cs";
                  desc = "+ Code spell";
                }
                {
                  mode = "n";
                  keys = "<leader>d";
                  desc = "+ Debugger";
                }
                {
                  mode = "n";
                  keys = "<leader>f";
                  desc = "+ Find";
                }
                {
                  mode = "n";
                  keys = "<leader>g";
                  desc = "+ Git";
                }
                {
                  mode = "n";
                  keys = "<leader>l";
                  desc = "+ Lsp";
                }
                {
                  mode = [
                    "n"
                    "x"
                    "i"
                  ];
                  keys = "<leader>o";
                  desc = "+ MiniOperators";
                }
                {
                  mode = "n";
                  keys = "<leader>n";
                  desc = "+ Notify";
                }
                {
                  mode = "n";
                  keys = "<leader>s";
                  desc = "+ Sessions";
                }
                {
                  mode = "n";
                  keys = "<leader>p";
                  desc = "+ Package";
                }
                {
                  mode = "n";
                  keys = "<leader>t";
                  desc = "+ Terminal";
                }
                {
                  mode = "n";
                  keys = "<leader>w";
                  desc = "+ Window";
                }
                {
                  mode = "n";
                  keys = "<leader>y";
                  desc = "+ Yank";
                }
                (lib.generators.mkLuaInline "require('mini.clue').gen_clues.builtin_completion()")
                (lib.generators.mkLuaInline "require('mini.clue').gen_clues.g()")
                (lib.generators.mkLuaInline "require('mini.clue').gen_clues.marks()")
                (lib.generators.mkLuaInline "require('mini.clue').gen_clues.registers()")
                (lib.generators.mkLuaInline "require('mini.clue').gen_clues.windows({ submode_resize = true })")
                (lib.generators.mkLuaInline "require('mini.clue').gen_clues.z()")
              ];
              triggers = [
                {
                  mode = "n";
                  keys = "<Leader>";
                }
                {
                  mode = "x";
                  keys = "<Leader>";
                }
                {
                  mode = "n";
                  keys = "\\";
                }
                {
                  mode = "n";
                  keys = "[";
                }
                {
                  mode = "n";
                  keys = "]";
                }
                {
                  mode = "x";
                  keys = "[";
                }
                {
                  mode = "x";
                  keys = "]";
                }
                {
                  mode = "i";
                  keys = "<C-x>";
                }
                {
                  mode = "n";
                  keys = "g";
                }
                {
                  mode = "x";
                  keys = "g";
                }
                {
                  mode = "n";
                  keys = "'";
                }
                {
                  mode = "n";
                  keys = "`";
                }
                {
                  mode = "x";
                  keys = "'";
                }
                {
                  mode = "x";
                  keys = "`";
                }
                {
                  mode = "n";
                  keys = "\\";
                }
                {
                  mode = "x";
                  keys = "\\";
                }
                {
                  mode = "i";
                  keys = "<C-r>";
                }
                {
                  mode = "c";
                  keys = "<C-r>";
                }
                {
                  mode = "n";
                  keys = "<C-w>";
                }
                {
                  mode = "n";
                  keys = "z";
                }
                {
                  mode = "x";
                  keys = "z";
                }
              ];
            };
          };
          # Lazy plugins modules
          lazy = {
            enable = true;
            plugins = {
              ${pkgs.vimPlugins.sidekick-nvim.pname} = {
                package = pkgs.vimPlugins.sidekick-nvim;
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
              ${pkgs.vimPlugins.nvim-navic.pname} = {
                package = pkgs.vimPlugins.nvim-navic;
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
              ${pkgs.vimPlugins.mini-sessions.pname} = {
                package = pkgs.vimPlugins.mini-sessions;
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
              ${pkgs.vimPlugins.mini-keymap.pname} = {
                package = pkgs.vimPlugins.mini-keymap;
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
              ${pkgs.vimPlugins.nvim-ts-context-commentstring.pname} = {
                package = pkgs.vimPlugins.nvim-ts-context-commentstring;
                lazy = true;
                setupOpts = {
                  enable_autocmd = false;
                };
              };
            };
          };
          # Keymap sections
          keymaps = [
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
              key = "n";
              mode = "n";
              action = "<s-n>nzzzv";
            }
            {
              key = L "nd";
              mode = "n";
              action = ''
                MiniNotify.clear
              '';
              lua = true;
              desc = "Notify: Dismiss";
            }
            {
              key = L "nh";
              mode = "n";
              action = ''
                MiniNotify.show_history
              '';
              lua = true;
              desc = "Notify: History";
            }
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
              action = ''
                function()
                  local ok = pcall(MiniFiles.open, vim.api.nvim_buf_get_name(0), false)
                  if not ok then
                    MiniFiles.open(nil, false)
                  end
                end
              '';
            }
            {
              key = L "E";
              mode = "n";
              desc = "Open explore (dir)";
              lua = true;
              action = ''
                function()
                  local ok = pcall(MiniFiles.open, nil, false)
                  if not ok then
                    MiniFiles.open(nil, false)
                  end
                end
              '';
            }
            {
              key = "<s-h>";
              mode = "n";
              desc = "Prev buffer";
              lua = true;
              action = ''
                function()
                  MiniBracketed.buffer('backward')
                end
              '';
            }
            {
              key = "<s-l>";
              mode = "n";
              desc = "Next buffer";
              lua = true;
              action = ''
                function()
                  MiniBracketed.buffer('forward')
                end
              '';
            }
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
            {
              key = L "yf";
              mode = "n";
              desc = "Yank full path";
              lua = true;
              action = ''
                function()
                  local path = vim.fn.expand("%:p")
                  if path == "" then
                    vim.notify("No file path to yank", vim.log.levels.WARN)
                    return
                  end
                  vim.fn.setreg("+", path)
                  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
                end
              '';
            }
            {
              key = L "yr";
              mode = "n";
              desc = "Yank relative path";
              lua = true;
              action = ''
                function()
                  local path = vim.fn.expand("%")
                  if path == "" then
                    vim.notify("No file path to yank", vim.log.levels.WARN)
                    return
                  end
                  vim.fn.setreg("+", path)
                  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
                end
              '';
            }
            {
              key = L "yd";
              mode = "n";
              desc = "Yank directory";
              lua = true;
              action = ''
                function()
                  local path = vim.fn.expand("%:p:h")
                  if path == "" then
                    vim.notify("No file path to yank", vim.log.levels.WARN)
                    return
                  end
                  vim.fn.setreg("+", path)
                  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
                end
              '';
            }
            {
              key = L "yn";
              mode = "n";
              desc = "Yank filename";
              lua = true;
              action = ''
                function()
                  local path = vim.fn.expand("%:t")
                  if path == "" then
                    vim.notify("No file path to yank", vim.log.levels.WARN)
                    return
                  end
                  vim.fn.setreg("+", path)
                  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
                end
              '';
            }
            {
              key = L "ff";
              mode = "n";
              desc = "Find files";
              lua = true;
              action = "MiniPick.builtin.files";
            }
            {
              key = L "fw";
              mode = [
                "n"
                "v"
              ];
              desc = "Find word (Grep)";
              lua = true;
              action = ''
                function()
                  local getMode = vim.api.nvim_get_mode().mode
                  if getMode == "v" then
                    MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") })
                  elseif getMode == "n" then
                    MiniPick.builtin.grep_live()
                  end
                end
              '';
            }
            {
              key = L "fb";
              mode = "n";
              desc = "Find buffers";
              lua = true;
              action = "MiniPick.builtin.buffers";
            }
            {
              key = L "fh";
              mode = "n";
              desc = "Find help";
              lua = true;
              action = "MiniPick.builtin.help";
            }
            {
              key = L "fR";
              mode = "n";
              desc = "Find resume";
              lua = true;
              action = "MiniPick.builtin.resume";
            }
            {
              key = L "fr";
              mode = "n";
              desc = "Find registers";
              lua = true;
              action = "MiniExtra.pickers.registers";
            }
            {
              key = L "fc";
              mode = "n";
              desc = "Find commands";
              lua = true;
              action = "MiniExtra.pickers.commands";
            }
            {
              key = L "fk";
              mode = "n";
              desc = "Find keymaps";
              lua = true;
              action = "MiniExtra.pickers.keymaps";
            }
            {
              key = L "fm";
              mode = "n";
              desc = "Find marks";
              lua = true;
              action = "MiniExtra.pickers.marks";
            }
            {
              key = L "fH";
              mode = "n";
              desc = "Find history";
              lua = true;
              action = "MiniExtra.pickers.history";
            }
            {
              key = L "fv";
              mode = "n";
              desc = "Find visit paths";
              lua = true;
              action = "MiniExtra.pickers.visit_paths";
            }
            {
              key = L "fV";
              mode = "n";
              desc = "Find visit labels";
              lua = true;
              action = "MiniExtra.pickers.visit_labels";
            }
            {
              key = L "fq";
              mode = "n";
              desc = "Find quickfix";
              lua = true;
              action = ''function() MiniExtra.pickers.list({ scope = "quickfix" }) end'';
            }
            {
              key = L "fl";
              mode = "n";
              desc = "Find buffer lines";
              lua = true;
              action = ''function() MiniExtra.pickers.buf_lines({ scope = "current" }) end'';
            }
            {
              key = L "fd";
              mode = "n";
              desc = "Find diagnostics (buffer)";
              lua = true;
              action = ''function() MiniExtra.pickers.diagnostic(nil, { scope = "current" }) end'';
            }
            {
              key = L "fD";
              mode = "n";
              desc = "Find diagnostics (all)";
              lua = true;
              action = ''function() MiniExtra.pickers.diagnostic(nil, { scope = "all" }) end'';
            }
            {
              key = L "ft";
              mode = "n";
              desc = "Find colorschemes";
              lua = true;
              action = "function() MiniExtra.pickers.colorschemes() end";
            }
            {
              key = L "fT";
              mode = "n";
              desc = "Find task comments";
              lua = true;
              action = ''
                function()
                  MiniExtra.pickers.hipatterns({
                    scope = "all",
                    highlighters = { "todo", "fixme", "note", "bug" },
                  })
                end
              '';
            }
            {
              key = L "fC";
              mode = "n";
              desc = "Find config files";
              lua = true;
              action = ''
                function()
                  MiniPick.builtin.files({ tool = "fd" }, { source = { cwd = vim.fn.stdpath("config") } })
                end
              '';
            }
            {
              key = L "fp";
              mode = "n";
              desc = "Find projects";
              lua = true;
              action = ''
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
              '';
            }
            {
              key = L "lr";
              mode = "n";
              desc = "LSP references";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "references" }) end'';
            }
            {
              key = L "ld";
              mode = "n";
              desc = "LSP definitions";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "definition" }) end'';
            }
            {
              key = L "lt";
              mode = "n";
              desc = "LSP type definitions";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end'';
            }
            {
              key = L "li";
              mode = "n";
              desc = "LSP implementations";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "implementation" }) end'';
            }
            {
              key = L "lD";
              mode = "n";
              desc = "LSP declarations";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "declaration" }) end'';
            }
            {
              key = L "ls";
              mode = "n";
              desc = "LSP symbols";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end'';
            }
            {
              key = L "lS";
              mode = "n";
              desc = "LSP workspace symbols";
              lua = true;
              action = ''function() MiniExtra.pickers.lsp({ scope = "workspace_symbol_live" }) end'';
            }
          ];
        };
      };
    };
  };
}
