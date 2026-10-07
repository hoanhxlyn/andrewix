return {
  "nvim-dap",
  dependencies = { "nvim-nio", "nvim-dap-ui", "nvim-dap-virtual-text" },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
    { "<F10>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<F11>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>dB", function()
      vim.ui.input({ prompt = "Breakpoint condition" }, function(condition)
        if condition then
          require("dap").set_breakpoint(condition)
        end
      end)
    end, desc = "Debug: Set Breakpoint" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    { "<leader>dl", "<cmd>DapShowLog<cr>", desc = "Debug: Show Log" },
    { "<leader>dp", function()
      vim.ui.input({ prompt = "Log point message" }, function(message)
        if message then
          require("dap").set_breakpoint(nil, nil, message)
        end
      end)
    end, desc = "Debug: Set Log Point" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: Toggle REPL" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debug: widget hover", mode = { "n", "v" } },
    { "<leader>dp", function() require("dap.ui.widgets").preview() end, desc = "Debug: widget preview", mode = { "n", "v" } },
    { "<leader>df", function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames) end, desc = "Debug: widget float frames" },
    { "<leader>ds", function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes) end, desc = "Debug: widget float scopes" },
  },
  after = function()
    local dap = require("dap")
    local dapui = require("dapui")
    dap.set_log_level("TRACE")

    for name, icon in pairs(_G.mininvim.icons.dap) do
      local sign_name = "Dap" .. name
      vim.fn.sign_define(sign_name, { text = icon, texthl = sign_name, linehl = "", numhl = "" })
    end

    require("nvim-dap-virtual-text").setup({
      enabled = true,
    })
    dapui.setup()

    for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }) do
      dap.adapters[adapter] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = {
            "${port}",
          },
        },
      }
    end

    local js_languages = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

    for _, language in ipairs(js_languages) do
      dap.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = 'Start Chrome with "localhost"',
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}",
          userDataDir = "${workspaceFolder}/.vscode/pwa-chrome-debug",
        },
      }
    end

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end,
}