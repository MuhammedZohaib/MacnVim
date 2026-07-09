return {
	{
		"saghen/blink.cmp",
		version = "1.*", -- prebuilt fuzzy matcher binary; no rust toolchain needed
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = vim.fn.executable("make") == 1 and "make install_jsregexp" or nil,
				dependencies = { "rafamadriz/friendly-snippets" },
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
		opts = {
			keymap = {
				preset = "none",
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-Space>"] = { "show", "fallback" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			},
			snippets = { preset = "luasnip" },
			sources = {
				default = { "lsp", "snippets", "path", "buffer" },
				providers = {
					buffer = { min_keyword_length = 3 },
				},
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				menu = {
					border = "rounded",
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "kind" },
						},
					},
				},
				documentation = {
					auto_show = true,
					window = { border = "rounded" },
				},
				ghost_text = { enabled = true },
			},
			cmdline = {
				enabled = true,
				keymap = { preset = "cmdline" },
				completion = { menu = { auto_show = true } },
			},
		},
		config = function(_, opts)
			require("blink.cmp").setup(opts)
			vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "LspCodeLens" })
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { check_ts = true },
	},
}
