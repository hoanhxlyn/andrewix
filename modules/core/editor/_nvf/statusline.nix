{mini}: {
  lualine = {
    enable = !mini.statusline;
    setupOpts = {
      sections = {
        lualine_a = ["mode"];
        lualine_b = ["branch" "diff" "diagnostics"];
        lualine_c = [
          {
            __unkeyed-1.__raw = ''
              function()
                local reg = vim.fn.reg_recording()
                if reg == "" then return "" end
                return "Recording @" .. reg
              end
            '';
            color = { bg = "#ff6b6b"; fg = "#1a1b26"; gui = "bold"; };
          }
          "filename"
        ];
        lualine_x = [
          "lsp_status"
          "filetype"
          "encoding"
          "filesize"
          "fileformat"
        ];
        lualine_y = ["searchcount"];
        lualine_z = ["progress"];
      };
    };
  };
}
