{
  lib,
  mini,
  self,
}: {
  snacks-nvim = {
    enable = true;
    setupOpts = {
      dashboard = {
        enabled = !mini.starter;
        preset = {
          header = lib.removeSuffix "\n" (builtins.readFile "${self}/config/arts/andrewix.txt");
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
            # snacks' "startup" section pulls load time from lazy.stats, which
            # nvf (nix-managed plugins, no lazy.nvim) does not provide -> use a
            # static footer instead. Must be raw Lua: a snacks Text needs the
            # string as the positional [1] alongside named hl/align, which a Nix
            # attrset can't express.
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
      notify = {
        enabled = !mini.notify;
        style = "compact";
        margin.top = 2;
      };
      styles.notification.wo.wrap = true;
    };
  };
  images.image-nvim.enable = true;
}
