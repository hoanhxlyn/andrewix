{
  ui2.enable = true;
  borders = {
    enable = true;
    globalStyle = "rounded";
  };
  nvim-ufo.enable = true;
  noice = {
    enable = false;
    setupOpts = {
      messages.enabled = true;
      notify.enabled = false;
      popupmenu.enabled = false;
      lsp = {
        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = false;
          "vim.lsp.util.stylize_markdown" = false;
          "cmp.entry.get_documentation" = false;
        };
        progress.enabled = false;
        message.enabled = false;
        hover.enabled = false;
        signature.enabled = false;
      };

      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        inc_rename = false;
        lsp_doc_border = false;
      };
    };
  };
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
