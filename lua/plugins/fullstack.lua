return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    opts = {
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        tsserver_max_memory = "auto",
        expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused" },
        jsx_close_tag = { enable = true, filetypes = { "javascriptreact", "typescriptreact" } },
      },
    },
  },
}
