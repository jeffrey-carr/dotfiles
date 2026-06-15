return {
	-- Modern, Fast Completion (Blink.cmp replaces nvim-cmp)
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "accept", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					snippets = {
						score_offset = -3,
						should_show_items = function(ctx)
							return ctx.trigger.initial_kind ~= "trigger_character"
						end,
					},
				},
			},
			signature = {
				enabled = true,
				window = { border = "rounded" },
			},
			completion = {
				documentation = {
					auto_show = true,
					window = { border = "rounded" },
				},
				menu = {
					border = "rounded",
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "kind" },
						},
						components = {
							label = {
								width = { fill = true },
							},
							label_description = {
								width = { max = 30 },
								text = function(ctx)
									local detail = ctx.label_description or ctx.item.detail
									if detail and detail ~= "" then
										return detail
									end
									return ""
								end,
								highlight = "BlinkCmpLabelDescription",
							},
						},
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},

	-- Autoclose pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Surround
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Mini Utilities
	{
		"echasnovski/mini.nvim",
		version = "*",
		config = function()
			-- Automatically adds pairs
			require("mini.pairs").setup()
			-- Better textobjects (e.g. 'va(' to select around parens)
			require("mini.ai").setup()
			-- File explorer alternative/companion
			require("mini.files").setup()
		end,
	},

	-- Snacks utility library
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			dashboard = { enabled = true },
			styles = {
				notification = {
					wo = {
						winblend = 0,
					},
				},
			},
		},
	},

	-- Wakatime (Conditional based on profile)
	-- {
	--   "wakatime/vim-wakatime",
	--   lazy = false,
	--   cond = function()
	--     -- Only load if we are home, as requested in old config
	--     return _G.jeff_profile.is_home
	--   end,
	-- },
}
