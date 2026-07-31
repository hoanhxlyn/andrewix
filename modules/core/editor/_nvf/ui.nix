{
  ui2.enable = false;
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
}
