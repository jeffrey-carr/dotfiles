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

	-- Modern Notifications
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#000000",
			})
			vim.notify = notify
		end,
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

	-- Winbar breadcrumbs (current scope via LSP)
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},

	-- Markdown Preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
}

