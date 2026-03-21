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

	-- CodeCompanion (AI Assistant)
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp", -- Optional: For completion
			"stevearc/dressing.nvim", -- Optional: For better UI
			"nvim-telescope/telescope.nvim", -- Optional: For searching
		},
		config = function()
			require("codecompanion").setup({
				adapters = {
					copilot = require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "gpt-4o",
							},
						},
					}),
					copilot = require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "gemini-3.0",
							},
						},
					}),
				},
				strategies = {
					chat = { adapter = "copilot" },
					inline = { adapter = "copilot" },
					agent = { adapter = "copilot" },
				},
				display = {
					chat = {
						window = {
							layout = "vertical", -- float, vertical, horizontal
							width = 0.4,
						},
					},
				},
			})
		end,
		keys = {
			{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion Chat" },
			{ "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
			{ "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to CodeCompanion Chat" },
		},
	},
}
