{
  __findFile,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.nvf.url = "github:notashelf/nvf";
  den.aspects.my._.editor._.nvf = {
    includes = [
      (<den/unfree> [
        "copilot-language-server"
      ])
    ];

    nixos = {pkgs, ...}: let
      L = key: "<leader>${key}";
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
          };
          globals.maplocalleader = "\\";
          clipboard.enable = true;
          extraPackages = with pkgs; [ueberzugpp];
          # LSP config
          lsp.enable = true;
          lsp.formatOnSave = true;
          lsp.inlayHints.enable = true;
          lsp.lspconfig.enable = true;
          lsp.lightbulb.enable = true;
          lsp.lightbulb.autocmd.enable = true;
          lsp.mappings = {
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
            css.format.type = ["biome" "prettierd"];
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
            typescript.extraDiagnostics.types = ["biomejs" "eslint_d"];
            typescript.format.type = ["biome" "prettierd"];
            typescript.lsp.servers = ["typescript-go"];
            yaml.enable = true;
          };
          # Spellcheck modules
          spellcheck = {
            enable = true;
            ignoreTerminal = true;
            ignoredFiletypes = ["markdown" "gitcommit" "toggleterm"];
            languages = ["en"];
            programmingWordlist.enable = true;
          };
          # UI modules
          ui.breadcrumbs.enable = true;
          # Utility modules
          utility.snacks-nvim.enable = true;
          utility.images.image-nvim.enable = true;
          # Autocomplete modules
          autocomplete.blink-cmp.enable = true;
          autocomplete.blink-cmp.friendly-snippets.enable = true;
          # Mini modules
          mini.ai.enable = true;
          mini.git.enable = true;
          mini.diff.enable = true;
          mini.misc.enable = true;
          mini.move.enable = true;
          mini.pick.enable = true;
          mini.files.enable = true;
          mini.extra.enable = true;
          mini.icons.enable = true;
          mini.pairs.enable = true;
          mini.basics.enable = true;
          mini.comment.enable = true;
          mini.starter.enable = true;
          mini.sessions.enable = true;
          mini.snippets.enable = true;
          mini.surround.enable = true;
          mini.bracketed.enable = true;
          mini.bufremove.enable = true;
          mini.operators.enable = true;
          mini.cursorword.enable = true;
          mini.hipatterns.enable = true;
          mini.statusline.enable = true;
          mini.tabline.enable = true;
          mini.notify.enable = true;
          mini.animate.enable = true;
          mini.trailspace.enable = true;
          mini.indentscope.enable = true;
          mini.jump.enable = true;
          mini.jump2d.enable = true;
          mini.visits.enable = true;
          mini.clue.enable = true;
          # Lazy pluygins modules
          lazy.enable = true;
          lazy.plugins = {
            ${pkgs.vimPlugins.nvim-ufo.pname} = {
              package = pkgs.vimPlugins.nvim-ufo;
              setupModule = "ufo";
              event = ["BufReadPost"];
              keys = [
                {
                  mode = "n";
                  key = "zO";
                  action = ''function() require("ufo").openAllFolds() end'';
                  desc = "Ufo: Open all folds";
                }
                {
                  mode = "n";
                  key = "zC";
                  action = ''function() require("ufo").closeAllFolds() end'';
                  desc = "Ufo: Close all folds";
                }
                {
                  mode = "n";
                  key = "zi";
                  action = ''function() require("ufo").inspect() end'';
                  desc = "Ufo: inspect fold";
                }
                {
                  mode = "n";
                  key = "zk";
                  action = ''                                
                    function()
                      local winid = require('ufo').peekFoldedLinesUnderCursor();
                      if not winid then 
                        vim.lsp.buf.hover(); 
                      end
                    end'';
                  desc = "Ufo: inspect fold";
                }
              ];
              setupOpts = {
                open_fold_hl_timeout = 150;
                preview = {
                  win_config = {
                    border = ["╔" "═" "╗" "║" "╝" "═" "╚" "║"];
                    winhighlight = "Normal:Folded";
                    winblend = 0;
                  };
                };
                provider_selector = ["lsp" "indent"];
              };
            };
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
                  action = ''function() require("sidekick.cli").toggle({ filter = {installed = true} }) end'';
                }
                {
                  mode = ["x"];
                  key = L "as";
                  desc = "Agent: send selection";
                  action = ''function() require("sidekick.cli").send({msg = "{this}"}, filter = { installed = true }) end'';
                }
                {
                  mode = "n";
                  key = L "af";
                  desc = "Agent: Send File";
                  action = ''function() require("sidekick.cli").send({ msg = "{file}", filter = {installed = true} }) end'';
                }
              ];
            };
          };
        };
      };
    };
  };
}
