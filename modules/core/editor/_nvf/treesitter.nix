{pkgs, ...}: {
  enable = true;
  highlight.enable = true;
  indent.enable = true;
  grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [regex];
  context.enable = true;
  context.setupOpts.max_lines = 3;
  context.setupOpts.mode = "topline";
  context.setupOpts.zindex = 30;
  textobjects.enable = true;
  textobjects.setupOpts.move = {
    enable = true;
    set_jumps = true;
    goto_next_start."]f" = "@function.outer";
    goto_prev_start."[f" = "@function.outer";
    goto_next_end."]F" = "@function.outer";
    goto_prev_end."[F" = "@function.outer";
  };
  autotagHtml.enable = true;
}
