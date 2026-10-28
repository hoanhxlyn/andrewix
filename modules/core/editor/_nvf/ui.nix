{
  ui2.enable = true;
  ui2.setupOpts.msg.targets = "msg";
  borders.enable = true;
  borders.globalStyle = "rounded";
  nvim-ufo.enable = true;
  noice.enable = false;
  noice.setupOpts = {
    messages.enabled = true;
    notify.enabled = false;
    popupmenu.enabled = false;
    lsp = {
      override."vim.lsp.util.convert_input_to_markdown_lines" = false;
      override."vim.lsp.util.stylize_markdown" = false;
      override."cmp.entry.get_documentation" = false;
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
  colorizer.enable = true;
  colorizer.setupOpts.filetypes = {
    css.tailwind = true;
    scss.tailwind = true;
    html.tailwind = true;
    javascript.tailwind = true;
    typescript.tailwind = true;
    javascriptreact.tailwind = true;
    typescriptreact.tailwind = true;
  };
  colorizer.setupOpts.user_default_options.RRGGBB = true;
  colorizer.setupOpts.user_default_options.rgb_fn = true;
  colorizer.setupOpts.user_default_options.hsl_fn = true;
}
