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
		config = function(_, opts)
			local tsc = require("treesitter-context")
			tsc.setup(opts)

			-- The context line is a floating window, and while any float is open nvim
			-- redraws the whole window on every scrolled line instead of scrolling the
			-- terminal. Inside a function taller than the screen the float never goes
			-- away, so holding j sent ~20MB/9s to tmux (vs ~1MB) and the display fell
			-- seconds behind. Hide it for the duration of a scroll burst. Only bring it
			-- back if this guard hid it, so a manual :TSContext disable sticks.
			local hidden_by_scroll = false
			local timer = assert(vim.uv.new_timer())
			local reenable = vim.schedule_wrap(function()
				if hidden_by_scroll then
					hidden_by_scroll = false
					tsc.enable()
				end
			end)

			vim.api.nvim_create_autocmd("WinScrolled", {
				group = vim.api.nvim_create_augroup("TSContextScrollGuard", { clear = true }),
				callback = function()
					if not hidden_by_scroll then
						if not tsc.enabled() then
							return
						end
						hidden_by_scroll = true
						tsc.disable()
					end
					timer:start(150, 0, reenable)
				end,
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		opts = {},
		event = { "BufReadPost", "BufNewFile" },
	},
}
