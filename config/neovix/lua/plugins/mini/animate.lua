local MiniAnimate = require("mini.animate")

MiniAnimate.setup({
  cursor = { enable = false },
  scroll = {
    enable = false,
    timing = MiniAnimate.gen_timing.quadratic({
      unit = "total",
    }),
  },
  resize = { enable = true },
  open = { enable = true },
  close = { enable = true },
})
