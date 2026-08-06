{
  lib,
  mini,
  ...
}: {
  snacks-nvim = {
    enable = true;
    setupOpts = {
      dashboard = {
        enabled = !mini.starter;
        preset = {
          # header = builtins.readFile "${self}/config/arts/andrewix.txt"; #ponytail: doesn't render header correctly
          keys = [
            {
              icon = " ";
              key = "f";
              desc = "Find File";
              action = ":lua Snacks.dashboard.pick('files')";
            }
            {
              icon = " ";
              key = "n";
              desc = "New File";
              action = ":ene | startinsert";
            }
            {
              icon = " ";
              key = "g";
              desc = "Find Text";
              action = ":lua Snacks.dashboard.pick('live_grep')";
            }
            {
              icon = " ";
              key = "r";
              desc = "Recent Files";
              action = ":lua Snacks.dashboard.pick('oldfiles')";
            }
            {
              icon = " ";
              key = "s";
              desc = "Restore Session";
              action = ":lua MiniSessions.select()";
            }
            {
              icon = " ";
              key = "q";
              desc = "Quit";
              action = ":qa";
            }
          ];
        };
        sections = [
          {section = "header";}
          {
            section = "keys";
            gap = 1;
            padding = 1;
          }
          {
            icon = " ";
            title = "Recent Files";
            section = "recent_files";
            indent = 2;
            padding = 1;
          }
          {
            text = lib.generators.mkLuaInline ''{ { "⚡ Nvf andrewix", hl = "footer", align = "center" } }'';
            padding = 1;
          }
        ];
      };
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
            layout = {
              preset = "sidebar";
              width = 0.3;
            };
          };
        };
      };
      animate.easing = lib.mkIf (!mini.animate) "inOutQuad";
      quickfile.enabled = false;
      gh.enabled = false;
      scroll.enabled = !mini.animate;
      lazygit.enabled = true;
      terminal.enabled = true;
      terminal.win.enter = false;
      bigfile.enabled = true;
      image.enabled = true;
      input.enabled = true;
      indent.enabled = !mini.indent_scope;
      notifier = {
        enabled = !mini.notify;
        style = "fancy";
        margin.top = 2;
      };
      styles.notification.wo.wrap = true;
    };
  };
  images.image-nvim.enable = true;
}
