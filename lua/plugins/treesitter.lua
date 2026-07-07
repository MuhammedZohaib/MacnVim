local function has_core_treesitter()
  if type(vim.treesitter) == "table" then
    return true
  end

  vim.schedule(function()
    vim.notify(
      "Neovim core Treesitter API is unavailable. Restart Neovim after plugin/runtime updates; check `:version` if this repeats.",
      vim.log.levels.ERROR
    )
  end)

  return false
end

local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter-parsers"

local function ensure_parser_install_dir()
  local parser_dir = parser_install_dir .. "/parser"
  local ok = pcall(vim.fn.mkdir, parser_dir, "p")
  if ok and vim.fn.isdirectory(parser_dir) == 1 then
    vim.opt.runtimepath:prepend(parser_install_dir)
    return parser_install_dir
  end

  vim.schedule(function()
    vim.notify(
      "Treesitter parser directory is not writable: " .. parser_install_dir,
      vim.log.levels.WARN
    )
  end)

  return nil
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    cond = has_core_treesitter,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    init = function()
      ensure_parser_install_dir()
    end,
    config = function()
      local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.schedule(function()
          vim.notify("nvim-treesitter API mismatch. Run :Lazy sync.", vim.log.levels.WARN)
        end)
        return
      end

      local opts = {
        ensure_installed = {
          "bash",
          "css",
          "dockerfile",
          "html",
          "javascript",
          "json",
          "jsonc",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        auto_install = false,
        highlight = {
          enable = true,
          disable = function(lang, bufnr)
            local ft = vim.bo[bufnr].filetype
            return lang == "markdown"
              or lang == "markdown_inline"
              or ft == "markdown"
              or ft == "gitcommit"
          end,
        },
        indent = {
          enable = true,
          disable = { "markdown", "python" },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      }

      local parser_dir = ensure_parser_install_dir()
      if parser_dir then
        opts.parser_install_dir = parser_dir
      end

      ts_configs.setup(opts)
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    cond = has_core_treesitter,
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
