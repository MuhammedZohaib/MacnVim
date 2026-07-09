return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        -- Keep empty: with globalstatus, disabling a filetype hides the whole
        -- statusline whenever that window is focused (neo-tree, dashboard).
        disabled_filetypes = { statusline = {} },
      },
      sections = {
        lualine_a = { { "mode", fmt = function(str) return " " .. str end } },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", { "filetype", icon_only = true } },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- dashboard must own VimEnter; bigfile hooks BufReadPre
    opts = {
      bigfile = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      lazygit = {},
      terminal = {},
      notifier = {
        enabled = true,
        timeout = 1800,
        width = { max = 72 },
      },
      scratch = {},
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            [[                                                            ]],
            [[ ███╗   ███╗ █████╗  ██████╗███╗   ██╗██╗   ██╗██╗███╗   ███╗ ]],
            [[ ████╗ ████║██╔══██╗██╔════╝████╗  ██║██║   ██║██║████╗ ████║ ]],
            [[ ██╔████╔██║███████║██║     ██╔██╗ ██║██║   ██║██║██╔████╔██║ ]],
            [[ ██║╚██╔╝██║██╔══██║██║     ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
            [[ ██║ ╚═╝ ██║██║  ██║╚██████╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
            [[ ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
            [[                                                            ]],
            [[            Full-stack editor, crafted to ship.             ]],
          }, "\n"),
          keys = {
            { icon = "", key = "f", desc = "Find file", action = ":FzfLua files" },
            { icon = "", key = "r", desc = "Recent files", action = ":FzfLua oldfiles" },
            { icon = "", key = "g", desc = "Live grep", action = ":FzfLua live_grep" },
            { icon = "", key = "n", desc = "New file", action = ":enew" },
            { icon = "", key = "e", desc = "Explorer", action = ":Neotree toggle" },
            { icon = "󰒲", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = "", key = "m", desc = "Mason", action = ":Mason" },
            { icon = "", key = "c", desc = "Config", action = ":edit ~/.config/nvim/init.lua" },
            { icon = "", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 0, padding = 1 },
          { section = "startup" },
        },
      },
    },
    keys = {
      { "<leader>.", function() Snacks.scratch() end, desc = "Scratch buffer" },
      { "<leader>f.", function() Snacks.scratch.select() end, desc = "Select scratch" },
    },
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = { enabled = false },
        hover = { enabled = false },
      },
      cmdline = {
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        },
      },
      messages = {
        enabled = true,
        view_search = false,
      },
      popupmenu = { enabled = true, backend = "nui" },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = { event = "msg_show", any = {
            { find = "written" },
            { find = "%d+L, %d+B" },
            { find = "%d+ changes?;" },
            { find = "%-%-No lines in buffer%-%-" },
          } },
          opts = { skip = true },
        },
      },
    },
  },

  {
    "NvChad/nvim-colorizer.lua",
    ft = {
      "css",
      "scss",
      "sass",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "html",
      "json",
      "jsonc",
      "yaml",
      "markdown",
    },
    opts = {
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        css = true,
        tailwind = "both",
      },
    },
  },
}
