return {
  "markview.nvim",
  ft = "markdown",
  after = function()
    local utils = require("config.utils")
    utils.map("n", utils.L("mp"), utils.C("MdRender toggle"), "Markdown preview (toggle)")
    utils.map("n", utils.L("mt"), utils.C("MdRender tab"), "Markdown preview in tab")
  end,
}