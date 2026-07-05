return {
  {
    name = "codesweep",
    dir = vim.fn.stdpath("config"),
    cmd = "CodeSweep",
    keys = { { "<leader>cs", "<cmd>CodeSweep<CR>", desc = "Code sweep (cleanup codebase)" } },
    config = function()
      require("codesweep").setup()
    end,
  },
}
