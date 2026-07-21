{lib}: {
  enable = true;
  config = {
    severity_sort = true;
    float = {
      borders = "rounded";
      source = "if_many";
      max_width = 80;
    };
    underline = lib.generators.mkLuaInline "{severity = vim.diagnostic.severity.ERROR }";
    signs.text = lib.generators.mkLuaInline ''
                 {
      	[vim.diagnostic.severity.ERROR] = "󰅙 " ,
      	[vim.diagnostic.severity.WARN] = "󰀦 ",
      	[vim.diagnostic.severity.INFO] = "󱈸 ",
      	[vim.diagnostic.severity.HINT] = "󰌵 ",
      } '';
    virtual_text = {
      source = "if_many";
      spacing = 2;
      format = lib.generators.mkLuaInline ''
        function(diagnostic)
        return diagnostic.message
        end
      '';
    };
  };
}
