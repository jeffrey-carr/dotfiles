return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "main",
		-- Force early load and high priority
		lazy = false,
		priority = 1000,
		config = function()
			-- Force the plugin's lua directory into the runtime path manually
			-- to bypass lazy.nvim loading race conditions.
			local plugin_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"
			vim.opt.rtp:append(plugin_path)

			-- Manual setup for nvim-treesitter execution (main branch has removed configs module)
			local ensure_installed = {
				"html_tags", -- required dependency for svelte
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
			}

			-- Ensure parsers are installed
			require("nvim-treesitter.install").install(ensure_installed)

			-- Enable syntax highlighting
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})

			-- Enable indentation
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
					if lang and vim.tbl_contains(ensure_installed, lang) then
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "BufRead",
		opts = { max_lines = 3, trim_scope = "outer" },
	},
}
