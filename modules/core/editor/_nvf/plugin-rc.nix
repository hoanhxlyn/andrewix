{
  inputs,
  lib,
}: {
  extra-lint = inputs.nvf.lib.nvim.dag.entryAnywhere ''
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
  mini-icons-mock = inputs.nvf.lib.nvim.dag.entryAnywhere ''
    MiniIcons.mock_nvim_web_devicons()
  '';
  iskeyword-append = inputs.nvf.lib.nvim.dag.entryAnywhere ''
    vim.opt.iskeyword:append({ "@", "-" })
  '';
  ts-error-translator = lib.mkForce (inputs.nvf.lib.nvim.dag.entryAnywhere ''
    require("ts-error-translator").setup({ auto_attach = true })
  '');
  snacks-terminal-helpers = inputs.nvf.lib.nvim.dag.entryAfter ["snacks-nvim"] ''
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
  mini-git-blame = inputs.nvf.lib.nvim.dag.entryAnywhere ''
    local blame_enabled = true
    local au_group = vim.api.nvim_create_augroup("MiniGitBlameGroup", { clear = true })
    local ns_id = vim.api.nvim_create_namespace("MiniGitBlame")

    local function clear_blame()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end

    local function diff_this()
      local buf_data = require("mini.git").get_buf_data(0)
      if not buf_data or not buf_data.root then
        vim.notify("Not in a git repository.", vim.log.levels.WARN, { title = "Git" })
        return
      end
      local root = buf_data.root
      local file_path_from_root = buf_data.file
      if not file_path_from_root then
        local abs_file_path = vim.api.nvim_buf_get_name(0)
        if not abs_file_path or abs_file_path == "" then
          vim.notify("Buffer has no file path.", vim.log.levels.WARN, { title = "Git" })
          return
        end
        local normalized_root = root:gsub("[\\/]", "/")
        local normalized_abs_path = abs_file_path:gsub("[\\/]", "/")
        if normalized_abs_path:find(normalized_root, 1, true) == 1 then
          file_path_from_root = normalized_abs_path:sub(#normalized_root + 2)
        else
          vim.notify("File is not inside the git repository: " .. root, vim.log.levels.WARN, { title = "Git" })
          return
        end
      end
      if not file_path_from_root or file_path_from_root == "" then
        vim.notify("Could not determine file path relative to git root.", vim.log.levels.WARN, { title = "Git" })
        return
      end
      local function create_diff_view(old_content, hash)
        local original_win = vim.api.nvim_get_current_win()
        local original_buf = vim.api.nvim_get_current_buf()
        vim.cmd("vnew")
        local new_buf = vim.api.nvim_get_current_buf()
        local ft = vim.api.nvim_get_option_value("filetype", { buf = original_buf })
        vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, vim.split(old_content, "\n", { plain = true }))
        vim.api.nvim_set_option_value("filetype", ft, { buf = new_buf })
        vim.api.nvim_set_option_value("readonly", true, { buf = new_buf })
        vim.api.nvim_set_option_value("buftype", "nofile", { buf = new_buf })
        local file_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(original_buf), ":t")
        vim.api.nvim_buf_set_name(new_buf, string.format("%s@%s", file_name, hash:sub(1, 7)))
        vim.cmd("diffthis")
        vim.api.nvim_set_current_win(original_win)
        vim.cmd("diffthis")
      end
      local function on_commit_selected(selection)
        if not selection then return end
        local hash = selection:match("^(%S+)")
        if not hash then return end
        local get_content_cmd = { "git", "-C", root, "show", hash .. ":" .. file_path_from_root }
        vim.system(get_content_cmd, { text = true }, function(content_obj)
          vim.schedule(function()
            local old_content = ""
            if content_obj.code == 0 then
              old_content = content_obj.stdout
            elseif not (content_obj.stderr and content_obj.stderr:match("exists on disk, but not in")) then
              vim.notify("Could not get file content from git: " .. (content_obj.stderr or ""), vim.log.levels.ERROR, { title = "Git" })
              return
            end
            create_diff_view(old_content, hash)
          end)
        end)
      end
      local get_log_cmd = { "git", "-C", root, "log", "--pretty=format:%h\t%s\t%ar", "--", file_path_from_root }
      vim.system(get_log_cmd, { text = true }, function(log_obj)
        vim.schedule(function()
          if log_obj.code ~= 0 or log_obj.stdout == "" then
            vim.notify("Could not get commit history for this file.", vim.log.levels.WARN, { title = "Git" })
            return
          end
          local commits = vim.split(log_obj.stdout, "\n", { trimempty = true })
          if #commits == 0 then
            vim.notify("No commits found for this file.", vim.log.levels.INFO, { title = "Git" })
            return
          end
          table.insert(commits, 1, "HEAD\tCurrent HEAD")
          vim.ui.select(commits, { prompt = "Diff against commit:" }, on_commit_selected)
        end)
      end)
    end

    local function toggle_blame()
      blame_enabled = not blame_enabled
      if not blame_enabled then clear_blame() end
      local msg = blame_enabled and "Blame annotations enabled" or "Blame annotations disabled"
      vim.notify(msg, vim.log.levels.INFO, { title = "Git" })
    end

    local function toggle_diff_style()
      local MiniDiff = require("mini.diff")
      local config = MiniDiff.config
      if config.view.style == "sign" then
        config.view.style = "number"
        vim.notify("Diff style set to: number", vim.log.levels.INFO, { title = "Git" })
      else
        config.view.style = "sign"
        vim.notify("Diff style set to: sign", vim.log.levels.INFO, { title = "Git" })
      end
      MiniDiff.setup(config)
    end

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

    vim.api.nvim_create_autocmd("CursorHold", {
      group = au_group,
      callback = function()
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
