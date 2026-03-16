return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		-- Force early load and high priority
		lazy = false,
		priority = 1000,
		config = function()
			-- Force the plugin's lua directory into the runtime path manually
			-- to bypass lazy.nvim loading race conditions.
			local plugin_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"
			vim.opt.rtp:append(plugin_path)

			-- Now attempt the setup
			local configs = require("nvim-treesitter.config")
			configs.setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"go",
					"typescript",
					"javascript",
					"html",
					"css",
					"scss",
					"svelte",
					"markdown",
					"markdown_inline",
					"json",
					"java",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = { max_lines = 3, trim_scope = "outer" },
	},
}

