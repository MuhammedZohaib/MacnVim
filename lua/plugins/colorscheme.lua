return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000, -- load before other plugins read highlights
    opts = {
      compile = false,
      commentStyle = { italic = true },
      keywordStyle = { italic = false },
      transparent = false,
      theme = "dragon",
      background = { dark = "dragon", light = "lotus" },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")
    end,
  },
}
