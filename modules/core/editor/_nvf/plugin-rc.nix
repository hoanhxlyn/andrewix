{
  inputs,
  lib,
}: let
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere entryAfter;
in {
  extra-lint = entryAnywhere ''
    local ok, lint = pcall(require, "lint")
    if ok then
      lint.linters_by_ft = vim.tbl_extend("force", lint.linters_by_ft or {}, {
        css = { "stylelint" },
        scss = { "stylelint" },
        typescript = vim.list_extend(lint.linters_by_ft.typescript or {}, { "oxlint" }),
        javascript = vim.list_extend(lint.linters_by_ft.javascript or {}, { "oxlint" }),
        typescriptreact = vim.list_extend(lint.linters_by_ft.typescriptreact or {}, { "oxlint" }),
        javascriptreact = vim.list_extend(lint.linters_by_ft.javascriptreact or {}, { "oxlint" }),
      })
    end
  '';
  mini-icons-mock = entryAnywhere ''
    MiniIcons.mock_nvim_web_devicons()
  '';
  iskeyword-append = entryAnywhere ''
    vim.opt.iskeyword:append({ "@", "-" })
  '';
  ts-error-translator = lib.mkForce (entryAnywhere ''
    require("ts-error-translator").setup({ auto_attach = true })
  '');
  snacks-terminal-helpers = entryAfter ["snacks-nvim"] ''
    local function get_terms()
      local terms = {}
      for i = 1, 20 do
        local term = Snacks.terminal.get(nil, { count = i, create = false })
        if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
          table.insert(terms, { id = i, term = term })
        end
      end
      return terms
    end
    _G.get_next_id = function()
      local terms = get_terms()
      local map = {}
      for _, t in ipairs(terms) do map[t.id] = true end
      for i = 1, 20 do
        if not map[i] then return i end
      end
      return #terms + 1
    end
    _G.kill_term = function(term)
      if term.destroy then
        term:destroy()
      else
        term:close()
        if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
          vim.api.nvim_buf_delete(term.buf, { force = true })
        end
      end
    end
    _G.get_terms = get_terms
  '';
  mini-git-blame = entryAnywhere ''
    local blame_enabled = true
    local au_group = vim.api.nvim_create_augroup("MiniGitBlameGroup", { clear = true })
    local ns_id = vim.api.nvim_create_namespace("MiniGitBlame")

    local function clear_blame()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end

    local function toggle_blame()
      blame_enabled = not blame_enabled
      if not blame_enabled then clear_blame() end
      local msg = blame_enabled and "Blame annotations enabled" or "Blame annotations disabled"
      vim.notify(msg, vim.log.levels.INFO, { title = "Git" })
    end

    vim.api.nvim_create_autocmd("CursorHold", {
      group = au_group,
      callback = function()
        local function get_relative_time(timestamp)
          local current_time = os.time()
          local diff = os.difftime(current_time, timestamp)
          local minutes = math.floor(diff / 60)
          local hours = math.floor(minutes / 60)
          local days = math.floor(hours / 24)
          if minutes < 1 then return "just now"
          elseif minutes < 60 then return string.format("%d mins ago", minutes)
          elseif hours < 24 then return string.format("%d hours ago", hours)
          elseif days <= 3 then return string.format("%d days ago", days)
          else return os.date("%m/%d/%Y", timestamp) end
        end
        if not blame_enabled then return end
        clear_blame()
        local MiniGit = require("mini.git")
        local buf_data = MiniGit.get_buf_data(0)
        if not buf_data or not buf_data.root then return end
        local root = buf_data.root
        local file = vim.fn.expand("%")
        local line = vim.fn.line(".")
        local cmd_list = { "git", "-C", root, "blame", "-L", string.format("%d,%d", line, line), "--porcelain", file }
        vim.system(cmd_list, { text = true }, function(obj)
          vim.schedule(function()
            if vim.api.nvim_win_get_cursor(0)[1] ~= line then return end
            if obj.code ~= 0 or obj.stdout == "" then return end
            local output = obj.stdout
            local author = output:match("author (.-)\n")
            local date_ts = output:match("author%-time (.-)\n")
            local summary = output:match("summary (.-)\n")
            local hash = output:match("^(%S+)")
            if hash and hash:match("^0+$") then
              vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
                virt_text = { { "  Not committed yet", "Comment" } },
                hl_mode = "combine",
              })
              return
            end
            if author and date_ts and summary then
              local rel_time = get_relative_time(tonumber(date_ts) or 0)
              local text = string.format(" (%s) %s -> %s", rel_time, author, summary)
              vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
                virt_text = { { text, "Comment" } },
                hl_mode = "combine",
              })
            end
          end)
        end)
      end,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
      group = au_group,
      callback = clear_blame,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniGitCommandSplit",
      callback = function(au_data)
        if au_data.data.git_subcommand ~= "blame" then return end
        local win_src = au_data.data.win_source
        vim.wo.wrap = false
        vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
        vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })
        vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
      end,
    })
  '';
}
