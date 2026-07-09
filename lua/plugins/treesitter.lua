-- nvim-treesitter `main` branch: opt-in per-filetype model.
-- Parsers + queries install into stdpath('data')/site (single location —
-- the old master-branch setup had three parser dirs shadowing each other,
-- which caused random decoration-provider errors until restart).

local ensure_installed = {
  "bash",
  "css",
  "dockerfile",
  "html",
  "javascript",
  "json",
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
}

-- Filetypes where treesitter highlighting stays off (regex syntax instead).
local highlight_skip = {
  gitcommit = true,
}

-- Filetypes keeping their own indent logic.
local indent_skip = {
  markdown = true,
  python = true,
  yaml = true,
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({}) -- default install_dir: stdpath('data')/site

      -- No standalone jsonc grammar on the main branch; json parser covers it.
      vim.treesitter.language.register("json", "jsonc")

      -- Async + idempotent: skips parsers already installed.
      ts.install(ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
        callback = function(args)
          local ft = args.match
          if highlight_skip[ft] then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft) or ft
          -- pcall: no parser for this lang -> silently keep regex syntax.
          if not pcall(vim.treesitter.start, args.buf, lang) then
            return
          end

          if not indent_skip[ft] then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
          -- Folding: global foldexpr in core/options.lua (native treesitter).
        end,
      })
    end,
  },

  {
    -- Move-only textobjects (]f/[f/]c/[c function and class jumps).
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    keys = {
      { "]f", function() require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next function" },
      { "]c", function() require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next class" },
      { "[f", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous function" },
      { "[c", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous class" },
    },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
