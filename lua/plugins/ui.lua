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
        disabled_filetypes = { statusline = { "neo-tree", "snacks_dashboard" } },
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
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "center" },
        },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    opts = {
      indent = { char = "|" },
      scope = { enabled = true, show_start = false },
      exclude = {
        filetypes = { "help", "lazy", "mason", "neo-tree", "snacks_notif", "snacks_dashboard", "qf", "terminal" },
      },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- dashboard must own VimEnter; bigfile hooks BufReadPre
    opts = {
      bigfile = { enabled = true },
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
            { icon = "", key = "s", desc = "Restore session", action = ":lua require('persistence').load()" },
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
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>ps", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>pl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>pd", function() require("persistence").stop() end, desc = "Stop session save" },
    },
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = { window = { width = 0.86 } },
  },

  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
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
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      local neoscroll = require("neoscroll")
      neoscroll.setup({
        mappings = {}, -- declare below for full control
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alongside = true,
        easing_function = "sine",
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
      })

      local keymap = {
        ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 160 }) end,
        ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 160 }) end,
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 350 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 350 }) end,
        ["<C-y>"] = function() neoscroll.scroll(-0.1, { move_cursor = false, duration = 80 }) end,
        ["<C-e>"] = function() neoscroll.scroll(0.1,  { move_cursor = false, duration = 80 }) end,
        ["zt"]    = function() neoscroll.zt({ half_win_duration = 180 }) end,
        ["zz"]    = function() neoscroll.zz({ half_win_duration = 180 }) end,
        ["zb"]    = function() neoscroll.zb({ half_win_duration = 180 }) end,
      }
      for k, fn in pairs(keymap) do
        vim.keymap.set({ "n", "v", "x" }, k, fn, { silent = true, desc = "Smooth scroll " .. k })
      end
    end,
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
