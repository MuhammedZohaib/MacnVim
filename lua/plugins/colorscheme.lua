return {
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_foreground = "material"
			-- better_performance writes per-filetype highlight caches into
			-- after/syntax/. With lazy-loading those caches go stale and race
			-- on file open, breaking highlighting intermittently. Off = all
			-- highlights defined upfront at colorscheme load (a few ms slower,
			-- fully reliable).
			vim.g.gruvbox_material_better_performance = 0
			vim.g.gruvbox_material_enable_italic = 1
			vim.g.gruvbox_material_enable_bold = 1

			-- Custom overrides: lift comments and diagnostics out of the muted
			-- default palette so they're clearly visible. Uses gruvbox's bright
			-- variants. Runs on every ColorScheme apply so it always sticks.
			local function tweak()
				local set = vim.api.nvim_set_hl
				local p = {
					bright_red = "#fb4934",
					bright_yellow = "#fabd2f",
					comment_grey = "#a89984",
					string_aqua = "#89b482",
					blue = "#7daea3",
					orange = "#e78a4e",
					purple = "#d3869b",
					yellow = "#d8a657",
					fg = "#d4be98",
					dim = "#7c6f64",
					err_bg = "#3c2021",
					warn_bg = "#3a2f1f",
				}

				-- Comments: neutral warm grey + italic. Visible but recedes, so
				-- comment-heavy files don't drown in colour.
				set(0, "Comment", { fg = p.comment_grey, italic = true })
				set(0, "@comment", { link = "Comment" })

				-- Strings: aqua, distinct against the grey comments.
				-- @string covers all languages; @string.documentation = docstrings
				-- (python triple-quote, etc), captured separately by treesitter.
				set(0, "String", { fg = p.string_aqua })
				set(0, "@string", { link = "String" })
				-- Docstrings: dim grey italic so they read as prose, distinct from
				-- both code strings (aqua) and the lighter comment grey.
				set(0, "@string.documentation", { fg = p.dim, italic = true })

				-- Identifiers: give variables, params and members distinct hues.
				set(0, "@variable", { fg = p.fg })                              -- plain variables: neutral
				set(0, "@variable.parameter", { fg = p.orange, italic = true }) -- function params / args
				set(0, "@variable.member", { fg = p.blue })                    -- object fields / properties
				set(0, "@property", { link = "@variable.member" })
				set(0, "@variable.builtin", { fg = p.purple, italic = true })  -- self / cls / this

				-- Literal values: one consistent colour for numbers/bools/constants.
				set(0, "@number", { fg = p.purple })
				set(0, "@number.float", { fg = p.purple })
				set(0, "@boolean", { fg = p.purple, italic = true })
				set(0, "@constant", { fg = p.purple })
				set(0, "@constant.builtin", { fg = p.purple, italic = true })
				-- Unused/unnecessary code stays dim so it reads as "faded", not as a comment.
				set(0, "DiagnosticUnnecessary", { fg = p.dim, italic = true })

				-- Errors: loud red, curly underline, tinted virtual text.
				set(0, "DiagnosticError", { fg = p.bright_red })
				set(0, "DiagnosticUnderlineError", { undercurl = true, sp = p.bright_red })
				set(0, "DiagnosticVirtualTextError", { fg = p.bright_red, bg = p.err_bg, bold = true })
				set(0, "Error", { fg = p.bright_red, bold = true })
				set(0, "ErrorMsg", { fg = p.bright_red, bold = true })

				-- Warnings: clearer amber.
				set(0, "DiagnosticWarn", { fg = p.bright_yellow })
				set(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = p.bright_yellow })
				set(0, "DiagnosticVirtualTextWarn", { fg = p.bright_yellow, bg = p.warn_bg })

				-- Info/Hint: subtle blue undercurl so they don't compete with errors.
				set(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = p.blue })
				set(0, "DiagnosticUnderlineHint", { undercurl = true, sp = p.dim })
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("GruvboxTweaks", { clear = true }),
				pattern = "gruvbox-material",
				callback = tweak,
			})

			vim.cmd.colorscheme("gruvbox-material")
			-- Belt-and-suspenders: apply once directly and once after startup,
			-- in case any plugin re-links groups late in the load sequence.
			tweak()
			vim.schedule(tweak)
		end,
	},
}
