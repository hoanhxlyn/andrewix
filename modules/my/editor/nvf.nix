{
  __findFile,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.nvf.url = "github:notashelf/nvf";

  den.aspects.my._.editor._.nvf = {
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
          };
          globals.maplocalleader = "\\";
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
              format = L "cf";
              hover = L "lh";
              goToDefinition = L "ld";
              goToDeclaration = L "lD";
              goToType = L "lt";
              listReferences = L "lr";
              listDocumentSymbols = L "ls";
              listImplementations = L "li";
              listWorkspaceSymbols = L "lS";
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
            context.enable = true;
            context.setupOpts.max_lines = 3;
            context.setupOpts.mode = "topline";
            context.setupOpts.zindex = 30;
            textobjects.enable = true;
            textobjects.setupOpts = {
              move = {
                enable = true;
                set_jumps = true;
              };
            };
            autotagHtml.enable = true;
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
            lua.enable = true;
            lua.extraDiagnostics.types = ["selene"];
            lua.lsp.lazydev.enable = true;
            markdown.enable = true;
            markdown.extensions.markview-nvim.enable = true;
            markdown.lsp.servers = ["markdown-oxide"];
            markdown.format.type = ["mdformat"];
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
            ui2.enable = true;
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
          utility.images.image-nvim.enable = true;

          # Autocomplete modules
          autocomplete.blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
            setupOpts = {
              keymap.preset = "enter";
              cmdline.keymap.preset = "cmdline";
            };
            sourcePlugins = {
              lazydev.enable = true;
              lazydev.package = "lazydev-nvim";
              lazydev.module = "lazydev.integrations.blink";
              emoji.enable = false;
              ripgrep.enable = true;
              spell.enable = true;
            };
          };
          # Mini modules
          mini.ai = {
            enable = true;
            setupOpts.custom_textobjects = {
              L = "MiniExtra.gen_ai_spec.line()";
              f = ''MiniAi.gen_spec.function_call({ name_pattern = "[%w_]" })'';
              F = ''MiniAi.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" })'';
              o = ''MiniAi.gen_spec.treesitter({ a = { "@block.outer", "@loop.outer", "@conditional.outer" }, i = { "@block.inner", "@loop.inner", "@conditional.inner" } })'';
              B = "MiniExtra.gen_ai_spec.line()";
              D = "MiniExtra.gen_ai_spec.line()";
              I = "MiniExtra.gen_ai_spec.line()";
              u = "MiniAi.gen_spec.function_call()";
              U = ''MiniAi.gen_spec.function_call({ name_pattern = "[%w_]" })'';
              N = "MiniExtra.gen_ai_spec.line()";
            };
          };
          mini.git.enable = true;
          mini.diff.enable = true;
          mini.misc.enable = true;
          mini.move.enable = true;
          mini.pick.enable = mini.picks;
          mini.files = {
            enable = mini.explorer;
            setupOpts = {
              windows.preview = true;
              windows.width_focus = 30;
              windows.width_preview = 30;
              mappings = {
                go_out_plus = "h";
                synchronize = "<c-s>";
                show_help = "?";
              };
              content.filter = lib.mkLuaInline ''
                function(fs_entry)
                  if ${mini.show_dotfiles} then return true;
                  return not vim.startswith(fs_entry, ".")
                end
              '';
            };
          };
          mini.extra.enable = true;
          mini.icons.enable = true;
          mini.pairs = {
            enable = true;
            setupOpts = {
              skip_next = ''[=[%w%%%'%[%]"%.%`%$]='';
              skip_unbalanced = true;
            };
          };
          mini.basics = {
            enable = true;
            setupOpts = {
              options.basic = true;
              options.extra_ui = true;
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
          mini.snippets.enable = true;
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
              exchanges.prefix = "<Leader>ox";
              multiply.prefix = "<Leader>om";
              replace.prefix = "<Leader>or";
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
          mini.animate.enable = mini.animate;
          mini.trailspace.enable = true;
          mini.indentscope = {
            enable = mini.indent_scope;
            setupOpts = {
              options.try_as_border = true;
            };
          };
          mini.jump.enable = true;
          mini.jump2d.enable = true;
          mini.visits.enable = true;
          mini.clue = {
            enable = true;
            setupOpts = {
              window.config.width = "auto";
              window.config.anchor = "SW";
              window.config.row = "auto";
              window.config.col = "auto";
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
                setupOpts = {
                  highlight = true;
                  depth_limit = 4;
                  lsp.auto_attach = true;
                  lazy_update_context = true;
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
          ];
        };
      };
    };
  };
}
