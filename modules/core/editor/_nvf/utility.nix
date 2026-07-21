{
  lib,
  mini,
}: {
  snacks-nvim = {
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
