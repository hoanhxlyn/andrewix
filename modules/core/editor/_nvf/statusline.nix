{mini}: {
  lualine = {
    enable = !mini.statusline;
    setupOpts = {
      options.section_separators = {
        left = "";
        right = "";
      };
      sections = {
        lualine_a = ["mode"];
        lualine_b = ["branch" "diff" "diagnostics"];
        lualine_c = ["filename"];
        lualine_x = [
          "lsp_status"
          "filetype"
          "encoding"
          "filesize"
          "fileformat"
        ];
        lualine_y = ["searchcount"];
        lualine_z = [
          "location"
          "progress"
        ];
      };
    };
  };
}
