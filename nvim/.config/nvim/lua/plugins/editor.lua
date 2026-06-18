return {
	-- Fzf-Lua (High-performance fuzzy finder)
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
				fzf = {
					["ctrl-d"] = "preview-page-down",
					["ctrl-u"] = "preview-page-up",
				},
			},
			files = {
				fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude 'mocks' --exclude 'mock_*'",
			},
			grep = {
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob '!mocks/**' --glob '!mock_*' -e",
			},
			lsp = {
				jump1 = true,
				regex_filter = function(item)
					return not item.filename:match("/mocks/") and not item.filename:match("/mock_")
				end,
			},
		},
		keys = {
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fr", function() require("fzf-lua").lsp_references({ includeDeclaration = false }) end, desc = "Find References" },
			{ "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", desc = "Find Definitions" },
			{ "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", desc = "Find Implementation" },
			{ "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Find Symbols" },
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
				width = 55,
				popup = {
					size = { width = "80%" },
				},
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

	-- Flash (Modern cursor movement and treesitter navigation)
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			modes = {
				search = {
					enabled = false, -- Set to true if you want labels on regular `/` searches
				},
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
	},

	-- Todo Comments (Actionable comment highlighting)
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
		event = "BufReadPost",
		opts = {},
		keys = {
			{ "<leader>ft", "<cmd>TodoFzfLua<cr>", desc = "Find Todos (Project)" },
			{
				"<leader>fT",
				function()
					require("todo-comments.fzf").todo({
						filename = vim.fn.expand("%:p"),
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
				options = {
					multilines = {
						enabled = true,
						always_show = false,
					},
				},
			})
			vim.diagnostic.config({ virtual_text = false })
		end,
	},

	-- Grug-Far (Search and Replace)
	{
		"MagicDuck/grug-far.nvim",
		opts = { transient = true, openTargetWindow = { preferredLocation = 'prev' } },
		keys = {
			{
				"<leader>gr",
				function()
					require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
				end,
				mode = { "n" },
				desc = "Search & Replace (word)",
			},
			{
				"<leader>gr",
				function()
					require("grug-far").with_visual_selection()
				end,
				mode = { "v" },
				desc = "Search & Replace (selection)",
			},
			{
				"<leader>gf",
				function()
					require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
				end,
				desc = "Search & Replace (file)",
			},
			{
				"<leader>gg",
				function()
					require("grug-far").open()
				end,
				desc = "Search & Replace",
			},
		},
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
