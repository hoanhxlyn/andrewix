{
  host,
  mini,
}: let
  # wl-copy needs a Wayland compositor, which WSL doesn't run; bridge
  # nvim's clipboard to the Windows clipboard via win32yank instead
  # (`scoop install win32yank` on the Windows side).
  win32yank = "/mnt/c/Users/${host.windowsName}/scoop/root/apps/win32yank/current/win32yank.exe";
in {
  options = {
    wrap = false;
    shiftwidth = 2;
    tabstop = 2;
    foldcolumn = "auto";
    foldlevel = 99;
    foldlevelstart = 99;
    foldenable = true;
    scrolloff = 3;
    showmode = false;
    formatoptions = "jcroqlnt";
    grepformat = "%f:%l:%c:%m";
    grepprg = "rg; --vimgrep";
    updatetime = 500;
    winborder = "rounded";
    cursorline = true;
  };
  globals = {
    maplocalleader = "\\";
    mini_show_dotfiles = mini.show_dotfiles;
  };
  clipboard = {
    enable = true;
    registers = "unnamedplus";
    providers.wl-copy.enable = !host.wsl.enable;
  };
  luaConfigRC = {
    wsl-clipboard =
      if host.wsl.enable
      then ''
        vim.g.clipboard = {
          name = "win32yank-wsl",
          copy = {
            ["+"] = "${win32yank} -i --crlf",
            ["*"] = "${win32yank} -i --crlf",
          },
          paste = {
            ["+"] = "${win32yank} -o --lf",
            ["*"] = "${win32yank} -o --lf",
          },
          cache_enabled = 0,
        }
      ''
      else "";
    # stylix.targets.nvf.transparentBackground gets clobbered: nvf's
    # base16 plugin repaints Normal opaque after stylix runs. Re-clear on
    # every ColorScheme so the transparent terminal shows through.
    transparent-bg =
      if host.terminal.opacity < 1
      then ''
        local function clear_bg()
          for _, g in ipairs({ "Normal", "NormalNC", "NormalFloat",
            "SignColumn", "LineNr", "FoldColumn", "EndOfBuffer", "MsgArea" }) do
            local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
            hl.bg = "none"
            vim.api.nvim_set_hl(0, g, hl)
          end
        end
        vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bg })
        clear_bg()
      ''
      else "";
  };
}
