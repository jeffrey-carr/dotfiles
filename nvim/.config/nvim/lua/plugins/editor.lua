return {
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			defaults = {
				-- Telescope respects .gitignore by default for find_files if using fd/rg/git
				file_ignore_patterns = {
					"mocks",
					"mock_",
					"%.git/",
				},
			},
		},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fr", "<cmd> Telescope lsp_references<cr>", desc = "Telescope find references" },
			{ "<leader>fd", "<cmd>Telescope lsp_definitions<cr>", desc = "Telescope find definitions" },
			{ "<leader>fi", "<cmd>Telescope lsp_implementations<cr>", desc = "Telescope find implementation" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Telescope find symbols" },
		},
	},

	-- Neo-tree (High-polish Explorer)
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"antosha417/nvim-lsp-file-operations",
		},
		keys = {
			{
				"<leader>e",
				function()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
							vim.cmd("Neotree close")
							return
						end
					end
					vim.cmd("Neotree focus")
				end,
				desc = "Toggle Explorer",
			},
		},
		opts = {
			close_if_last_window = true,
			enable_git_status = true,
			source_selector = {
				winbar = true,
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.opt_local.relativenumber = true
					end,
				},
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_hidden = false,
				},
				follow_current_file = { enabled = true },
			},
			window = {
				width = 40,
				mappings = {
					["<space>"] = "none",
					["<Tab>"] = "next_source",
					["<S-Tab>"] = "prev_source",
				},
			},
		},
	},
	-- Window picker (used by neotree)
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		config = function()
			require("window-picker").setup({
				hint = "floating-big-letter",
			})
		end,
	},

	-- UI Improvements (Nicer inputs and selects)
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- Leap (Cursor movement)
	{
		url = "https://codeberg.org/andyg/leap.nvim",
		config = function()
			vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
			vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
		end,
	},

	-- Todo Comments (Actionable comment highlighting)
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		event = "BufReadPost",
		opts = {},
		keys = {
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find Todos (Project)" },
			{
				"<leader>fT",
				function()
					require("telescope").extensions["todo-comments"]["todo-comments"]({
						search_dirs = { vim.fn.expand("%:p") },
					})
				end,
				desc = "Find Todos (Buffer)",
			},
		},
	},

	-- Trouble (Diagnostics list)
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
		},
		opts = {},
	},

	-- Which-Key (Keybind hints)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},

	-- WindowSwap
	{
		"wesQ3/vim-windowswap",
		init = function()
			vim.g.windowswap_map_keys = 0 -- prevent default keymaps
		end,
		keys = {
			{ "<leader>ww", "<cmd>call WindowSwap#EasyWindowSwap()<CR>", desc = "Swap window" },
		},
	},

	-- Cellular Automaton
	{
		"Eandrju/cellular-automaton.nvim",
		keys = {
			{ "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "Make it rain" },
		},
	},

	-- Inline Diagnostics
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "modern",
			})
			vim.diagnostic.config({ virtual_text = false })
		end,
	},

	-- Goto Preview
	{
		"rmagatti/goto-preview",
		keys = {
			{ "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview Definition" },
			{ "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "Preview Type Def" },
			{
				"gpi",
				"<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
				desc = "Preview Implementation",
			},
			{ "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close All Previews" },
		},
		config = function()
			require("goto-preview").setup({})
		end,
	},
}
