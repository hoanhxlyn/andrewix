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
      environment.systemPackages = with pkgs; [
        ueberzugpp
        graphicsmagick
        graphicsmagick-imagemagick-compat
        tectonic
        mermaid-cli
        sqlite
        ghostscript
      ];
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
            updatetime = 500;
            winborder = "rounded";
            cursorline = true;
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
          extraPackages = with pkgs; [ueberzugpp stylelint oxlint kdlfmt];
          # LSP config
          lsp = {
            enable = true;
            formatOnSave = true;
            inlayHints.enable = true;
            lspconfig.enable = true;
            mappings = {
              codeAction = L "ca";
              nextDiagnostic = "]d";
              previousDiagnostic = "[d";
              openDiagnosticFloat = L "cd";
              renameSymbol = L "cr";
              signatureHelp = "<c-/>";
            };
            presets = {
              tailwindcss-language-server.enable = true;
              typescript-go.enable = true;
              vscode-css-language-server.enable = true;
            };
            servers = {
              typescript-go.filetypes = [
                "typescript"
                "javascript"
                "typescriptreact"
                "javascriptreact"
              ];

              tailwindcss-languages-server.settings.tailwindCSS.classFunctions = [
                "cva"
                "cx"
                "tv"
              ];
              nil.settings = {
                nil.nix.flake.autoArchive = true;
              };
              vscode-css-language-server.settings.css.lint.unknownAtRules = "ignore";
              jsonls = {
                filetypes = ["json" "jsonc" "bak"];
                settings.json = {
                  format.enable = false;
                  schemas = lib.generators.mkLuaInline ''
                    require("schemastore").json.schemas({
                      extra = {
                        {
                          description = "Shadcn JSON schema",
                          fileMatch = { "components.json" },
                          name = "components.json",
                          url = "https://ui.shadcn.com/schema.json",
                        },
                        {
                          description = "Lua_ls JSON schema",
                          fileMatch = { ".luarc.json" },
                          name = ".luarc.json",
                          url = "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
                        },
                      },
                    })
                  '';
                };
              };
              yamlls.settings.yaml = {
                schemaStore = {
                  enable = false;
                  url = "";
                };
                schemas = lib.generators.mkLuaInline ''require("schemastore").yaml.schemas()'';
              };
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
                goto_next_start."]f" = "@function.outer";
                goto_prev_start."[f" = "@function.outer";
                goto_next_end."]F" = "@function.outer";
                goto_prev_end."[F" = "@function.outer";
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
            css.format.type = [
              "biome"
              "prettierd"
            ];
            scss.enable = true;
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
            typescript = {
              enable = true;
              extensions.ts-error-translator.enable = true;
              extraDiagnostics.types = [
                "biomejs"
                "eslint_d"
              ];
              format.type = [
                "biome"
                "prettierd"
              ];
              lsp.servers = ["typescript-go"];
            };
            yaml.enable = true;
            fish.enable = true;
            xml.enable = true;
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
            borders = {
              enable = true;
              globalStyle = "rounded";
            };
            nvim-ufo.enable = true;
            colorizer = {
              enable = true;
              setupOpts = {
                filetypes = {
                  css = {tailwind = true;};
                  scss = {tailwind = true;};
                  html = {tailwind = true;};
                  javascript = {tailwind = true;};
                  typescript = {tailwind = true;};
                  javascriptreact = {tailwind = true;};
                  typescriptreact = {tailwind = true;};
                };
                user_default_options = {
                  RRGGBB = true;
                  rgb_fn = true;
                  hsl_fn = true;
                };
              };
            };
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
              notify = {
                enabled = !mini.notify;
                style = "compact";
                margin.top = 2;
              };
              styles.notification.wo.wrap = true;
            };
          };
          pluginRC.extra-lint = inputs.nvf.lib.nvim.dag.entryAnywhere ''
            local ok, lint = pcall(require, "lint")
            if ok then
              lint.linters_by_ft = vim.tbl_extend("force", lint.linters_by_ft or {}, {
                css = { "stylelint" },
                scss = { "stylelint" },
                typescript = vim.list_extend(lint.linters_by_ft.typescript or {}, { "oxlint" }),
                javascript = vim.list_extend(lint.linters_by_ft.javascript or {}, { "oxlint" }),
                typescriptreact = vim.list_extend(lint.linters_by_ft.typescriptreact or {}, { "oxlint" }),
                javascriptreact = vim.list_extend(lint.linters_by_ft.javascriptreact or {}, { "oxlint" }),
              })
            end
          '';
          pluginRC.mini-icons-mock = inputs.nvf.lib.nvim.dag.entryAnywhere ''
            MiniIcons.mock_nvim_web_devicons()
          '';
          pluginRC.iskeyword-append = inputs.nvf.lib.nvim.dag.entryAnywhere ''
            vim.opt.iskeyword:append({ "@", "-" })
          '';
          pluginRC.ts-error-translator = lib.mkForce (inputs.nvf.lib.nvim.dag.entryAnywhere ''
            require("ts-error-translator").setup({ auto_attach = true })
          '');
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
          pluginRC.mini-git-blame = inputs.nvf.lib.nvim.dag.entryAnywhere ''
            local blame_enabled = true
            local au_group = vim.api.nvim_create_augroup("MiniGitBlameGroup", { clear = true })
            local ns_id = vim.api.nvim_create_namespace("MiniGitBlame")

            local function clear_blame()
              vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
            end

            local function diff_this()
              local buf_data = require("mini.git").get_buf_data(0)
              if not buf_data or not buf_data.root then
                vim.notify("Not in a git repository.", vim.log.levels.WARN, { title = "Git" })
                return
              end
              local root = buf_data.root
              local file_path_from_root = buf_data.file
              if not file_path_from_root then
                local abs_file_path = vim.api.nvim_buf_get_name(0)
                if not abs_file_path or abs_file_path == "" then
                  vim.notify("Buffer has no file path.", vim.log.levels.WARN, { title = "Git" })
                  return
                end
                local normalized_root = root:gsub("[\\/]", "/")
                local normalized_abs_path = abs_file_path:gsub("[\\/]", "/")
                if normalized_abs_path:find(normalized_root, 1, true) == 1 then
                  file_path_from_root = normalized_abs_path:sub(#normalized_root + 2)
                else
                  vim.notify("File is not inside the git repository: " .. root, vim.log.levels.WARN, { title = "Git" })
                  return
                end
              end
              if not file_path_from_root or file_path_from_root == "" then
                vim.notify("Could not determine file path relative to git root.", vim.log.levels.WARN, { title = "Git" })
                return
              end
              local function create_diff_view(old_content, hash)
                local original_win = vim.api.nvim_get_current_win()
                local original_buf = vim.api.nvim_get_current_buf()
                vim.cmd("vnew")
                local new_buf = vim.api.nvim_get_current_buf()
                local ft = vim.api.nvim_get_option_value("filetype", { buf = original_buf })
                vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, vim.split(old_content, "\n", { plain = true }))
                vim.api.nvim_set_option_value("filetype", ft, { buf = new_buf })
                vim.api.nvim_set_option_value("readonly", true, { buf = new_buf })
                vim.api.nvim_set_option_value("buftype", "nofile", { buf = new_buf })
                local file_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(original_buf), ":t")
                vim.api.nvim_buf_set_name(new_buf, string.format("%s@%s", file_name, hash:sub(1, 7)))
                vim.cmd("diffthis")
                vim.api.nvim_set_current_win(original_win)
                vim.cmd("diffthis")
              end
              local function on_commit_selected(selection)
                if not selection then return end
                local hash = selection:match("^(%S+)")
                if not hash then return end
                local get_content_cmd = { "git", "-C", root, "show", hash .. ":" .. file_path_from_root }
                vim.system(get_content_cmd, { text = true }, function(content_obj)
                  vim.schedule(function()
                    local old_content = ""
                    if content_obj.code == 0 then
                      old_content = content_obj.stdout
                    elseif not (content_obj.stderr and content_obj.stderr:match("exists on disk, but not in")) then
                      vim.notify("Could not get file content from git: " .. (content_obj.stderr or ""), vim.log.levels.ERROR, { title = "Git" })
                      return
                    end
                    create_diff_view(old_content, hash)
                  end)
                end)
              end
              local get_log_cmd = { "git", "-C", root, "log", "--pretty=format:%h\t%s\t%ar", "--", file_path_from_root }
              vim.system(get_log_cmd, { text = true }, function(log_obj)
                vim.schedule(function()
                  if log_obj.code ~= 0 or log_obj.stdout == "" then
                    vim.notify("Could not get commit history for this file.", vim.log.levels.WARN, { title = "Git" })
                    return
                  end
                  local commits = vim.split(log_obj.stdout, "\n", { trimempty = true })
                  if #commits == 0 then
                    vim.notify("No commits found for this file.", vim.log.levels.INFO, { title = "Git" })
                    return
                  end
                  table.insert(commits, 1, "HEAD\tCurrent HEAD")
                  vim.ui.select(commits, { prompt = "Diff against commit:" }, on_commit_selected)
                end)
              end)
            end

            local function toggle_blame()
              blame_enabled = not blame_enabled
              if not blame_enabled then clear_blame() end
              local msg = blame_enabled and "Blame annotations enabled" or "Blame annotations disabled"
              vim.notify(msg, vim.log.levels.INFO, { title = "Git" })
            end

            local function toggle_diff_style()
              local MiniDiff = require("mini.diff")
              local config = MiniDiff.config
              if config.view.style == "sign" then
                config.view.style = "number"
                vim.notify("Diff style set to: number", vim.log.levels.INFO, { title = "Git" })
              else
                config.view.style = "sign"
                vim.notify("Diff style set to: sign", vim.log.levels.INFO, { title = "Git" })
              end
              MiniDiff.setup(config)
            end

            local function get_relative_time(timestamp)
              local current_time = os.time()
              local diff = os.difftime(current_time, timestamp)
              local minutes = math.floor(diff / 60)
              local hours = math.floor(minutes / 60)
              local days = math.floor(hours / 24)
              if minutes < 1 then return "just now"
              elseif minutes < 60 then return string.format("%d mins ago", minutes)
              elseif hours < 24 then return string.format("%d hours ago", hours)
              elseif days <= 3 then return string.format("%d days ago", days)
              else return os.date("%m/%d/%Y", timestamp) end
            end

            vim.api.nvim_create_autocmd("CursorHold", {
              group = au_group,
              callback = function()
                if not blame_enabled then return end
                clear_blame()
                local MiniGit = require("mini.git")
                local buf_data = MiniGit.get_buf_data(0)
                if not buf_data or not buf_data.root then return end
                local root = buf_data.root
                local file = vim.fn.expand("%")
                local line = vim.fn.line(".")
                local cmd_list = { "git", "-C", root, "blame", "-L", string.format("%d,%d", line, line), "--porcelain", file }
                vim.system(cmd_list, { text = true }, function(obj)
                  vim.schedule(function()
                    if vim.api.nvim_win_get_cursor(0)[1] ~= line then return end
                    if obj.code ~= 0 or obj.stdout == "" then return end
                    local output = obj.stdout
                    local author = output:match("author (.-)\n")
                    local date_ts = output:match("author%-time (.-)\n")
                    local summary = output:match("summary (.-)\n")
                    local hash = output:match("^(%S+)")
                    if hash and hash:match("^0+$") then
                      vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
                        virt_text = { { "  Not committed yet", "Comment" } },
                        hl_mode = "combine",
                      })
                      return
                    end
                    if author and date_ts and summary then
                      local rel_time = get_relative_time(tonumber(date_ts) or 0)
                      local text = string.format(" (%s) %s -> %s", rel_time, author, summary)
                      vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
                        virt_text = { { text, "Comment" } },
                        hl_mode = "combine",
                      })
                    end
                  end)
                end)
              end,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
              group = au_group,
              callback = clear_blame,
            })

            vim.api.nvim_create_autocmd("User", {
              pattern = "MiniGitCommandSplit",
              callback = function(au_data)
                if au_data.data.git_subcommand ~= "blame" then return end
                local win_src = au_data.data.win_source
                vim.wo.wrap = false
                vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
                vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })
                vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
              end,
            })
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
          };
          mini = {
            # Mini modules
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
              setupOpts = {
                file = {
                  Brewfile = {
                    glyph = "󰂘";
                    hl = "MiniIconsYellow";
                  };
                  ".chezmoiignore" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".chezmoiremove" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".chezmoiroot" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".chezmoiversion" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".zshrc" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".zprofile" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".zshenv" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".zlogin" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".zlogout" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  "zsh.tmpl" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".bashrc" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".bash_profile" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".bash_aliases" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".bash_logout" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  "bash.tmpl" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  ".json" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".jsonc" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".bak" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".eslintrc.js" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc.json" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc.yaml" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc.yml" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc.cjs" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc.mjs" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc.ts" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".eslintrc" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.js" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.json" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.yaml" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.yml" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.cjs" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.mjs" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  "eslint.config.ts" = {
                    glyph = "󰱺";
                    hl = "MiniIconsPurple";
                  };
                  ".prettierrc" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.json" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.yaml" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.yml" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.json5" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.js" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.cjs" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.mjs" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".prettierrc.ts" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "prettier.config.js" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "prettier.config.cjs" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "prettier.config.mjs" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "prettier.config.ts" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "yarn.lock" = {
                    glyph = "";
                    hl = "MiniIconsBlue";
                  };
                  ".yarnrc.yml" = {
                    glyph = "";
                    hl = "MiniIconsBlue";
                  };
                  ".yarnrc.yaml" = {
                    glyph = "";
                    hl = "MiniIconsBlue";
                  };
                  "tsconfig.json" = {
                    glyph = "";
                    hl = "MiniIconsAzure";
                  };
                  "tsconfig.build.json" = {
                    glyph = "";
                    hl = "MiniIconsAzure";
                  };
                  "tsconfig.app.json" = {
                    glyph = "";
                    hl = "MiniIconsAzure";
                  };
                  "tsconfig.server.json" = {
                    glyph = "";
                    hl = "MiniIconsAzure";
                  };
                  "tsconfig.web.json" = {
                    glyph = "";
                    hl = "MiniIconsAzure";
                  };
                  "tsconfig.client.json" = {
                    glyph = "";
                    hl = "MiniIconsAzure";
                  };
                  ".node-version" = {
                    glyph = "";
                    hl = "MiniIconsGreen";
                  };
                  "package.json" = {
                    glyph = "";
                    hl = "MiniIconsGreen";
                  };
                  ".npmrc" = {
                    glyph = "";
                    hl = "MiniIconsGreen";
                  };
                  "vite.config.ts" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "vite.config.js" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "pnpm-lock.yaml" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  "pnpm-workspace.yaml" = {
                    glyph = "";
                    hl = "MiniIconsYellow";
                  };
                  ".dockerignore" = {
                    glyph = "󰡨";
                    hl = "MiniIconsBlue";
                  };
                  "react-router.config.ts" = {
                    glyph = "";
                    hl = "MiniIconsRed";
                  };
                  "react-router.config.js" = {
                    glyph = "";
                    hl = "MiniIconsRed";
                  };
                  "bun.lockb" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  "bun.lock" = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  "agents.md" = {
                    glyph = "󰚩";
                    hl = "MiniIconsGrey";
                  };
                  "AGENTS.md" = {
                    glyph = "󰚩";
                    hl = "MiniIconsGrey";
                  };
                };
                directory = {
                  ".vscode" = {
                    glyph = "";
                    hl = "MiniIconsBlue";
                  };
                  cspell = {
                    glyph = "󰓆";
                    hl = "MiniIconsPurple";
                  };
                  config = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  configs = {
                    glyph = "";
                    hl = "MiniIconsGrey";
                  };
                  app = {
                    glyph = "󰀻";
                    hl = "MiniIconsRed";
                  };
                  application = {
                    glyph = "󰀻";
                    hl = "MiniIconsRed";
                  };
                  routes = {
                    glyph = "󰑪";
                    hl = "MiniIconsGreen";
                  };
                  route = {
                    glyph = "󰑪";
                    hl = "MiniIconsGreen";
                  };
                  router = {
                    glyph = "󰑪";
                    hl = "MiniIconsGreen";
                  };
                  routers = {
                    glyph = "󰑪";
                    hl = "MiniIconsGreen";
                  };
                  server = {
                    glyph = "󰒋";
                    hl = "MiniIconsCyan";
                  };
                  servers = {
                    glyph = "󰒋";
                    hl = "MiniIconsCyan";
                  };
                  api = {
                    glyph = "󰒋";
                    hl = "MiniIconsCyan";
                  };
                  web = {
                    glyph = "󰖟";
                    hl = "MiniIconsBlue";
                  };
                  client = {
                    glyph = "󰖟";
                    hl = "MiniIconsBlue";
                  };
                  frontend = {
                    glyph = "󰖟";
                    hl = "MiniIconsBlue";
                  };
                  database = {
                    glyph = "󰆼";
                    hl = "MiniIconsOrange";
                  };
                  db = {
                    glyph = "󰆼";
                    hl = "MiniIconsOrange";
                  };
                  databases = {
                    glyph = "󰆼";
                    hl = "MiniIconsOrange";
                  };
                };
                lsp = {
                  copilot = {
                    glyph = "";
                    hl = "MiniIconsBlue";
                  };
                };
              };
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
                highlighters = {
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
                    desc = "+ Operators";
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
              ${pkgs.vimPlugins.diffview-nvim.pname} = {
                package = pkgs.vimPlugins.diffview-nvim;
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
              ${pkgs.vimPlugins.SchemaStore-nvim.pname} = {
                package = pkgs.vimPlugins.SchemaStore-nvim;
              };
            };
          };
          # Keymap sections
          keymaps = [
            {
              key = L "h";
              mode = "n";
              desc = "Open Dashboard";
              lua = true;
              action = "MiniStarter.open";
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
              key = L "nc";
              mode = "n";
              lua = true;
              desc = "Notify: Clear all";
              action = ''function() Snacks.notif.hide() end'';
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
            {
              key = L "bo";
              mode = "n";
              desc = "Delete other buffers";
              lua = true;
              action = ''
                function()
                  local cur = vim.api.nvim_get_current_buf()
                  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].buflisted and buf ~= cur then
                      MiniBufremove.delete(buf, true)
                    end
                  end
                end
              '';
            }
            {
              key = L "bL";
              mode = "n";
              desc = "Delete buffers to the right";
              lua = true;
              action = ''
                function()
                  local cur = vim.fn.bufnr()
                  local bufs = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
                  local after = false
                  for _, b in ipairs(bufs) do
                    if after then MiniBufremove.delete(b, true)
                    elseif b == cur then after = true end
                  end
                end
              '';
            }
            {
              key = L "bH";
              mode = "n";
              desc = "Delete buffers to the left";
              lua = true;
              action = ''
                function()
                  local cur = vim.fn.bufnr()
                  local bufs = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
                  for _, b in ipairs(bufs) do
                    if b == cur then break end
                    MiniBufremove.delete(b, true)
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
              action = ''function() require("mini.extra").pickers.git_commits({ path = vim.api.nvim_buf_get_name(0) }) end'';
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
              desc = "Open in Nautilus";
              lua = true;
              action = ''
                function()
                  local path = vim.fn.expand("%:p")
                  if path == "" then
                    vim.notify("No file path", vim.log.levels.WARN)
                    return
                  end
                  vim.fn.jobstart({"nautilus", "-s", path})
                end
              '';
            }
          ];
        };
      };
    };
  };
}
