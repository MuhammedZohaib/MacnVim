-- ============================================================
-- init.lua — Neovim entry point
-- ============================================================
pcall(vim.loader.enable) -- bytecode cache for faster startup on 0.9+

require("core.options")
require("plugins.colorscheme")[1].config()
require("core.keymaps")
require("core.autocmds")
require("core.lazy") -- Plugin manager bootstrap
