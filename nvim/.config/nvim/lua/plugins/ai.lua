return {
	-- GitHub Copilot (Classic)
	{
		"github/copilot.vim",
		config = function()
			vim.g.copilot_no_tab_map = true
			-- Accept full suggestion
			vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
			-- Accept partial suggestions
			vim.api.nvim_set_keymap("i", "<C-J>", "copilot#AcceptWord()", { silent = true, expr = true })
			vim.api.nvim_set_keymap("i", "<M-j>", "copilot#AcceptLine()", { silent = true, expr = true })
			-- Re-generate / Manual Suggest
			vim.api.nvim_set_keymap("i", "<M-;>", "copilot#Suggest()", { silent = true, expr = true })
			-- Enable/disable
			vim.api.nvim_set_keymap(
				"n",
				"<leader>ace",
				"<cmd>Copilot enable<cr>",
				{ silent = true, desc = "Enable Copilot" }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>acd",
				"<cmd>Copilot disable<cr>",
				{ silent = true, desc = "Disable Copilot" }
			)
		end,
	},

	-- Agentic.nvim (AI Assistant via Claude Code)
	{
		"carlos-algms/agentic.nvim",
		opts = {
			provider = "claude-agent-acp",
			windows = {
				position = "right",
				width = "40%",
			},
		},
		keys = {
			{
				"<C-\\>",
				function()
					require("agentic").toggle()
				end,
				mode = { "n", "v", "i" },
				desc = "Toggle Agentic chat",
			},
			{
				"<C-'>",
				function()
					require("agentic").add_selection_or_file_to_context()
				end,
				mode = { "n", "v" },
				desc = "Add selection/file to Agentic context",
			},
			{
				"<leader>aan",
				function()
					require("agentic").new_session()
				end,
				mode = { "n", "v" },
				desc = "New Agentic session",
			},
			{
				"<leader>aar",
				function()
					require("agentic").restore_session()
				end,
				desc = "Restore Agentic session",
				mode = { "n" },
			},
			{
				"<leader>aad", -- ai Diagnostics
				function()
					require("agentic").add_current_line_diagnostics()
				end,
				desc = "Add current line diagnostic to Agentic",
				mode = { "n" },
			},
			{
				"<leader>aaD", -- ai all Diagnostics
				function()
					require("agentic").add_buffer_diagnostics()
				end,
				desc = "Add all buffer diagnostics to Agentic",
				mode = { "n" },
			},
		},
	},
}
