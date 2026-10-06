return {
  "config",
  keys = {
    { "<leader>aa", desc = "Agent: Open/Focus" },
    { "<leader>as", mode = { "x", "n" }, desc = "Agent: Send Selection" },
    { "<leader>af", desc = "Agent: Send File" },
    { "<leader>ax", desc = "Agent: Close" },
  },
  after = function()
    require("plugins.herdr_agent").setup()
  end,
}