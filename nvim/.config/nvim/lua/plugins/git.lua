return {
	-- Gitsigns
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git Blame Line" },
			{ "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Git Preview Hunk" },
			{ "<leader>gh", "<cmd>Gitsigns diffthis<cr>", desc = "Git Diff Split (Current File)" },
		},
		opts = {
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			watch_gitdir = {
				follow_files = true,
			},
			attach_to_untracked = true,

			-- OPTIMIZATIONS:
			current_line_blame = false,
			update_debounce = 250, -- Increased from 100 to reduce update frequency while scrolling
			max_file_length = 10000, -- Disable on files > 10,000 lines

			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 500,
				ignore_whitespace = false,
			},
			preview_config = {
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
		},
	},

	-- Lazygit
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},

	-- Diffview (Full UI diff viewer)
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diffview (Project)" },
			{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Git Diffview Close" },
		},
	},
}
