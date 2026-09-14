return {
	-- Bufferline (Cokeline)
	{
		"willothy/nvim-cokeline",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		config = function()
			local get_hex = require("cokeline.hlgroups").get_hl_attr

			local function hl(group, attr)
				local ok, val = pcall(get_hex, group, attr)
				return ok and val or "NONE"
			end

			require("cokeline").setup({
				show_if_buffers_are_at_least = 1,
				fill_hl = "TabLineFill",

				default_hl = {
					fg = function(buffer)
						return buffer.is_focused and hl("ColorColumn", "bg") or hl("Normal", "fg")
					end,
					bg = function(buffer)
						return buffer.is_focused and hl("Normal", "fg") or hl("ColorColumn", "bg")
					end,
				},

				components = {
					-- Devicon (always shown)
					{
						text = function(buffer) return " " .. buffer.devicon.icon end,
						fg   = function(buffer) return buffer.devicon.color end,
					},
					-- Unique path prefix (only shown when two buffers share a filename)
					{
						text      = function(buffer) return buffer.unique_prefix end,
						fg        = function(_) return hl("Comment", "fg") end,
						italic    = true,
						truncation = { priority = 1 },
					},
					-- Filename; underline on hover (unfocused only)
					{
						text = function(buffer) return buffer.filename end,
						underline = function(buffer)
							return buffer.is_hovered and not buffer.is_focused
						end,
						truncation = { priority = 2 },
					},
					-- Diagnostic badge (errors take priority over warnings)
					{
						text = function(buffer)
							if buffer.diagnostics.errors   > 0 then return "  " .. buffer.diagnostics.errors   end
							if buffer.diagnostics.warnings > 0 then return "  " .. buffer.diagnostics.warnings end
							return ""
						end,
						fg = function(buffer)
							if buffer.diagnostics.errors   > 0 then return hl("DiagnosticError", "fg") end
							if buffer.diagnostics.warnings > 0 then return hl("DiagnosticWarn",  "fg") end
						end,
					},
					-- Modified indicator (right-aligned, space before for separation)
					{
						text = function(buffer) return buffer.is_modified and " ● " or "   " end,
						fg   = function(buffer)
							if buffer.is_modified then return hl("DiagnosticWarn", "fg") end
						end,
					},
					-- Close button
					{
						text = "󰅙 ",
						on_click = function(_, _, _, _, buffer) buffer:delete() end,
					},
				},
			})
		end,
	},

	-- Indent Guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Smooth cursor animations
	{
		"sphamba/smear-cursor.nvim",
		opts = {},
	},


	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { { "mode", icon = "" } },
				lualine_b = {
					{ "branch", icon = "" },
				},
				lualine_c = {
					{ "filename", path = 1, symbols = { modified = "  ", readonly = " 󰌾 ", unnamed = "  " } },
				},
				lualine_x = { { "filetype" } },
				lualine_y = { "progress" },
				lualine_z = {
					"location",
					{ function() return os.date("󱑎 %H:%M") end },
				},
			},
		},
	},

	-- Winbar breadcrumbs (current scope via LSP/Treesitter, click-navigable)
	{
		"Bekaboo/dropbar.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			icons = {
				enable = true,
			},
			bar = {
				padding = { left = 1, right = 1 },
			},
		},
		config = function(_, opts)
			require("dropbar").setup(opts)
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick symbol in breadcrumbs" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next breadcrumb context" })
		end,
	},

	-- Markdown Preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {
			checkbox = {
				custom = {
					cancelled = { raw = "[~]", rendered = "󰜺 ", highlight = "DiagnosticError", scope_highlight = "Comment" },
					important = { raw = "[!]", rendered = "󰀦 ", highlight = "DiagnosticWarn" },
					forwarded = { raw = "[>]", rendered = "󰑃 ", highlight = "RenderMarkdownTodo" },
				},
			},
		},
	},

	-- Line Justice (Dual Absolute & Relative Line Numbers)
	{
		"zaakiy/line-justice.nvim",
		dependencies = {
			"luukvbaal/statuscol.nvim",
			"lewis6991/gitsigns.nvim",
		},
		lazy = false,
		config = function()
			local lj = require("line-justice")
			lj.setup()

			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
					{
						sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, auto = true },
						click = "v:lua.ScSa",
					},
					{ sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true }, click = "v:lua.ScSa" },
					{
						sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
						click = "v:lua.ScSa",
					},
					{ text = { lj.segment }, click = "v:lua.ScLa" },
				},
			})
		end,
	},

	-- Code Biscuits (Treesitter Context Annotations)
	{
		"code-biscuits/nvim-biscuits",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		event = "BufRead",
		config = function()
			require("nvim-biscuits").setup({
				cursor_line_only = true,
				default_config = {
					max_length = 60, -- Max characters for the virtual text
					min_distance = 5, -- Only show biscuit if the block is at least this many lines long
					prefix_string = " 󰊠 ", -- Adds a nice icon before the biscuit text
					show_on_start = true,
				},
			})
			-- Turn down opacity by linking to the much dimmer 'LspInlayHint' or 'NonText' highlight group
			vim.api.nvim_set_hl(0, "BiscuitColor", { link = "LspInlayHint" })

			-- PATCH: Fix nvim-biscuits showing the wrong line for Go functions by ignoring internal blocks
			local langs = require("nvim-biscuits.languages")
			local orig_should_decorate = langs.should_decorate
			langs.should_decorate = function(language_name, ts_node, text, bufnr)
				if language_name == "go" then
					local type = ts_node:type()
					if type == "block" or type == "statement_list" then
						return false
					end
				end
				return orig_should_decorate(language_name, ts_node, text, bufnr)
			end
		end,
	},
}

