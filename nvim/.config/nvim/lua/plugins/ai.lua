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

			-- Enable/Disable/Toggle. Under <leader>ag rather than <leader>ac, which
			-- would otherwise make the AI pane's <leader>ac wait out the mapping timeout.
			vim.keymap.set("n", "<leader>age", "<cmd>Copilot enable<cr>", { silent = true, desc = "Enable Copilot" })
			vim.keymap.set("n", "<leader>agd", "<cmd>Copilot disable<cr>", { silent = true, desc = "Disable Copilot" })
			vim.keymap.set("n", "<leader>agt", function()
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

	-- Claude Code's IDE protocol (diffs, live selection, @-mentions). The CLI itself
	-- runs in a tmux pane, and the pane keys (<leader>ac, af, an, ar, aC, ap) work for
	-- any CLI -- see config/ai_tmux.lua. Only Claude speaks this protocol, so the
	-- plugin loads only when ai_tmux picked Claude. lazy.nvim keeps the lock file
	-- entry of a plugin whose cond is false, so lazy-lock.json matches on every machine.
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		cond = function()
			return require("config.ai_tmux").ide
		end,
		-- Not lazy on cmd/keys: the IDE server has to be up at startup so a Claude
		-- already running in tmux can /ide into this Neovim.
		event = "VeryLazy",
		opts = function()
			local ai = require("config.ai_tmux")
			return {
				terminal_cmd = ai.cmd,
				-- Routes through provider.open(), which focuses the tmux pane.
				focus_after_send = true,
				-- Chosen once here rather than via provider.is_available(): claudecode
				-- re-resolves the provider on every cursor move (selection tracking)
				-- and logs a fallback warning each time the custom one says no.
				terminal = { provider = ai.in_tmux() and ai.provider or "auto" },
				diff_opts = { layout = "vertical", open_in_new_tab = false },
			}
		end,
		keys = {
			{
				"<leader>aR",
				function()
					require("config.ai_tmux").reconnect()
				end,
				desc = "Reconnect Claude (/ide)",
			},
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file to Claude",
				ft = { "neo-tree", "oil", "minifiles" },
			},
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude diff" },
		},
	},
}
