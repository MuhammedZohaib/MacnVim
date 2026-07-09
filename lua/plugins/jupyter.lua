-- ============================================================
-- jupyter.lua — Jupyter notebook workflow
--   .ipynb  <-> plain text         : jupytext.nvim
--   IPython REPL                   : iron.nvim
--   cell navigation / execution    : NotebookNavigator.nvim
--
-- External deps (install once):
--   pip install jupytext ipython
-- ============================================================
return {
  -- Transparently convert .ipynb to/from a `# %%` cell-marked python
  -- buffer on read/write. Keeps git diffs and LSP/formatters working.
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- must register the BufReadCmd before any .ipynb opens
    opts = {
      style = "hydrogen", -- emits `# %%` markers NotebookNavigator understands
      output_extension = "auto",
      force_ft = nil,
    },
  },

  -- IPython REPL. send_motion combined with cell text object lets you
  -- ship a whole cell to the kernel.
  {
    "Vigemus/iron.nvim",
    ft = { "python", "julia", "r" },
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = function()
                local exe = vim.fn.executable("ipython") == 1 and "ipython" or "python3"
                return exe == "ipython" and { "ipython", "--no-autoindent" } or { "python3" }
              end,
              format = common.bracketed_paste_python,
            },
          },
          repl_open_cmd = view.split.vertical.botright(0.42),
        },
        keymaps = {
          toggle_repl = "<leader>jr",
          restart_repl = "<leader>jR",
          send_motion = "<leader>js",
          visual_send = "<leader>js",
          send_file = "<leader>jf",
          send_line = "<leader>jL",
          interrupt = "<leader>ji",
          exit = "<leader>jQ",
          clear = "<leader>jK",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },

  -- Cell navigation + execution over the `# %%` markers.
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {
      "Vigemus/iron.nvim",
    },
    ft = { "python", "julia", "r" },
    keys = {
      { "]j", function() require("notebook-navigator").move_cell("d") end, desc = "Next cell" },
      { "[j", function() require("notebook-navigator").move_cell("u") end, desc = "Previous cell" },
      { "<leader>jx", function() require("notebook-navigator").run_cell() end, desc = "Run cell" },
      { "<leader>jj", function() require("notebook-navigator").run_and_move() end, desc = "Run cell and move" },
      { "<leader>ja", function() require("notebook-navigator").run_all_cells() end, desc = "Run all cells" },
      { "<leader>jb", function() require("notebook-navigator").run_cells_below() end, desc = "Run cells below" },
      -- TODO: comment_cell needs Comment.nvim or mini.comment backend; no-ops since Comment.nvim removal
      { "<leader>jc", function() require("notebook-navigator").comment_cell() end, desc = "Comment cell" },
      { "<leader>jo", function() require("notebook-navigator").add_cell_below() end, desc = "Add cell below" },
      { "<leader>jO", function() require("notebook-navigator").add_cell_above() end, desc = "Add cell above" },
    },
    config = function()
      require("notebook-navigator").setup({
        repl_provider = "iron",
        cell_markers = { python = "# %%" },
        syntax_highlight = true,
      })
    end,
  },
}
