return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Seamless <C-hjkl> movement across nvim splits and tmux panes. Falls back
  -- to plain window navigation when not running inside tmux. Pairs with the
  -- christoomey/vim-tmux-navigator entry already in ~/.tmux.conf.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Window/pane left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Window/pane down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Window/pane up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Window/pane right" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>s", group = "Splits/Search" },
        { "<leader>t", group = "Terminal/TypeScript" },
        { "<leader>ts", group = "TypeScript" },
        { "<leader>x", group = "Diagnostics" },
      },
    },
  },
}
