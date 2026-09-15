-- Parsers this config manages. kulala.nvim installs its own `kulala_http`
-- parser, which nvim-treesitter has no grammar for, so a bare `:TSUpdate`
-- errors on it. Updating this explicit list instead keeps it quiet.
local ensure_installed = {
	"html_tags", -- required dependency for svelte
	"c",
	"lua",
	"vim",
	"vimdoc",
	"query",
	"go",
	"python",
	"typescript",
	"javascript",
	"html",
	"css",
	"scss",
	"svelte",
	"markdown",
	"markdown_inline",
	"json",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter.install").update(ensure_installed, { summary = true })
		end,
		branch = "main",
		-- Force early load and high priority
		lazy = false,
		priority = 1000,
		config = function()
			-- Force the plugin's lua directory into the runtime path manually
			-- to bypass lazy.nvim loading race conditions.
			local plugin_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"
			vim.opt.rtp:append(plugin_path)

			-- Ensure parsers are installed
			-- (main branch has removed the configs module, so this is manual)
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
		opts = { max_lines = 1, trim_scope = "outer" },
	},
	{
		"windwp/nvim-ts-autotag",
		opts = {},
		event = { "BufReadPost", "BufNewFile" },
	},
}
