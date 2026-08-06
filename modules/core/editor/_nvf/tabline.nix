{
  lib,
  mini,
}: {
  nvimBufferline = {
    enable = !mini.tabline;
    # keymaps live in keymaps.nix — suppress nvf's vendored <leader>b* binds
    mappings = {
      closeCurrent = null;
      cycleNext = null;
      cyclePrevious = null;
      pick = null;
      sortByExtension = null;
      sortByDirectory = null;
      sortById = null;
      moveNext = null;
      movePrevious = null;
    };
    setupOpts.options = {
      mode = "buffers";
      numbers = "none";
      sort_by = "id"; # mini.tabline orders by buffer id
      always_show_bufferline = true;
      show_buffer_close_icons = false;
      show_close_icon = false;
      separator_style = "thin";
      modified_icon = "󰏫";
      diagnostics = "nvim_lsp";
      # mini.tabline overrides the file icon instead; bufferline uses a separate column
      diagnostics_indicator = lib.generators.mkLuaInline ''
        function(_, _, diag)
          if diag.error then return "󰅙 " end
          if diag.warning then return "󰀦 " end
          return ""
        end
      '';
    };
  };
}
