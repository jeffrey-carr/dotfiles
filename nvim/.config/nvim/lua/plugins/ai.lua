return {
	-- GitHub Copilot (Classic)
	{
		"github/copilot.vim",
		config = function()
			vim.g.copilot_enabled = 0
			vim.g.copilot_no_tab_map = true

			-- Accept full suggestion
			vim.keymap.set("i", "<C-L>", 'copilot#Accept("<CR>")', {
				silent = true,
				expr = true,
				replace_keycodes = false,
				desc = "Copilot Accept Full",
			})

			-- Accept partial suggestions
			vim.keymap.set("i", "<C-J>", "copilot#AcceptWord()", {
				silent = true,
				expr = true,
				replace_keycodes = false,
				desc = "Copilot Accept Word",
			})
			vim.keymap.set("i", "<M-j>", "copilot#AcceptLine()", {
				silent = true,
				expr = true,
				replace_keycodes = false,
				desc = "Copilot Accept Line",
			})

			-- Re-generate / Manual Suggest (Refresh)
			vim.keymap.set("i", "<M-;>", "copilot#Suggest()", {
				silent = true,
				expr = true,
				replace_keycodes = false,
				desc = "Copilot Refresh/Suggest",
			})

			-- Enable/Disable/Toggle
			vim.keymap.set("n", "<leader>ace", "<cmd>Copilot enable<cr>", { silent = true, desc = "Enable Copilot" })
			vim.keymap.set("n", "<leader>acd", "<cmd>Copilot disable<cr>", { silent = true, desc = "Disable Copilot" })
			vim.keymap.set("n", "<leader>act", function()
				if vim.g.copilot_enabled == 0 then
					vim.cmd("Copilot enable")
					vim.notify("Copilot Enabled", vim.log.levels.INFO, { title = "Copilot" })
				else
					vim.cmd("Copilot disable")
					vim.notify("Copilot Disabled", vim.log.levels.INFO, { title = "Copilot" })
				end
			end, { silent = true, desc = "Toggle Copilot" })
		end,
	},
}
