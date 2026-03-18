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
			},
		},
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
