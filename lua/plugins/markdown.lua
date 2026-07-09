return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = { position = "inline" },
      code = {
        style = "full",
        width = "block",
        min_width = 60,
        border = "thin",
      },
      -- Raw view while editing the line, rendered everywhere else.
      render_modes = { "n", "c", "t" },
    },
  },
}
