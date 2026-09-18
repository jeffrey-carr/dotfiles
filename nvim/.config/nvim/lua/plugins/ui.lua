return {
	-- Bufferline (Cokeline)
	{
		"willothy/nvim-cokeline",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		config = function()
			local get_hex = require("cokeline.hlgroups").get_hl_attr

			local function hl(group, attr)
				local ok, val = pcall(get_hex, group, attr)
				return ok and val or "NONE"
			end

			require("cokeline").setup({
				show_if_buffers_are_at_least = 1,
				fill_hl = "TabLineFill",

				default_hl = {
					fg = function(buffer)
						return buffer.is_focused and hl("ColorColumn", "bg") or hl("Normal", "fg")
					end,
					bg = function(buffer)
						return buffer.is_focused and hl("Normal", "fg") or hl("ColorColumn", "bg")
					end,
				},

				components = {
					-- Devicon (always shown)
					{
						text = function(buffer) return " " .. buffer.devicon.icon end,
						fg   = function(buffer) return buffer.devicon.color end,
					},
					-- Unique path prefix (only shown when two buffers share a filename)
					{
						text      = function(buffer) return buffer.unique_prefix end,
						fg        = function(_) return hl("Comment", "fg") end,
						italic    = true,
						truncation = { priority = 1 },
					},
					-- Filename; underline on hover (unfocused only)
					{
						text = function(buffer) return buffer.filename end,
						underline = function(buffer)
							return buffer.is_hovered and not buffer.is_focused
						end,
						truncation = { priority = 2 },
					},
					-- Diagnostic badge (errors take priority over warnings)
					{
						text = function(buffer)
							if buffer.diagnostics.errors   > 0 then return "  " .. buffer.diagnostics.errors   end
							if buffer.diagnostics.warnings > 0 then return "  " .. buffer.diagnostics.warnings end
							return ""
						end,
						fg = function(buffer)
							if buffer.diagnostics.errors   > 0 then return hl("DiagnosticError", "fg") end
							if buffer.diagnostics.warnings > 0 then return hl("DiagnosticWarn",  "fg") end
						end,
					},
					-- Modified indicator (right-aligned, space before for separation)
					{
						text = function(buffer) return buffer.is_modified and " ● " or "   " end,
						fg   = function(buffer)
							if buffer.is_modified then return hl("DiagnosticWarn", "fg") end
						end,
					},
					-- Close button
					{
						text = "󰅙 ",
						on_click = function(_, _, _, _, buffer) buffer:delete() end,
					},
				},
			})
		end,
	},

	-- Indent Guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Smooth cursor animations
	{
		"sphamba/smear-cursor.nvim",
		opts = {},
		config = function(_, opts)
			require("smear_cursor").setup(opts)

			-- The animation can't keep up with rapid WinScrolled events during fast
			-- scrolling, which shows up as the cursor lagging/jumping around the
			-- screen. Turn it off for the duration of a scroll burst (debounced) so
			-- it only animates normal cursor movement, not scrolling. Also disable
			-- it entirely while a large buffer is focused, since it otherwise
			-- animates every cursor advance during insert-mode typing too.
			local smear = require("smear_cursor")
			local scroll_timer

			local function refresh_enabled(bufnr)
				smear.enabled = not require("config.bigbuf").is_large(bufnr)
			end

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				group = vim.api.nvim_create_augroup("SmearCursorBigBufGuard", { clear = true }),
				callback = function(args)
					refresh_enabled(args.buf)
				end,
			})

			vim.api.nvim_create_autocmd("WinScrolled", {
				group = vim.api.nvim_create_augroup("SmearCursorScrollGuard", { clear = true }),
				callback = function()
					smear.enabled = false
					if scroll_timer then
						scroll_timer:stop()
						scroll_timer:close()
					end
					scroll_timer = vim.uv.new_timer()
					scroll_timer:start(
						150,
						0,
						vim.schedule_wrap(function()
							refresh_enabled(vim.api.nvim_get_current_buf())
							if scroll_timer then
								scroll_timer:close()
								scroll_timer = nil
							end
						end)
					)
				end,
			})
		end,
	},


	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { { "mode", icon = "" } },
				lualine_b = {
					{ "branch", icon = "" },
				},
				lualine_c = {
					{ "filename", path = 1, symbols = { modified = "  ", readonly = " 󰌾 ", unnamed = "  " } },
				},
				lualine_x = { "%S", { "filetype" } },
				lualine_y = { "progress" },
				lualine_z = {
					"location",
					{ function() return os.date("󱑎 %H:%M") end },
				},
			},
		},
	},

	-- Winbar breadcrumbs (current scope via LSP/Treesitter, click-navigable)
	{
		"Bekaboo/dropbar.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			icons = {
				enable = true,
			},
			bar = {
				padding = { left = 1, right = 1 },
			},
		},
		config = function(_, opts)
			-- Winbar breadcrumbs recompute via LSP/treesitter on every cursor move
			-- through scopes, which adds up on large buffers. Wrap the plugin's own
			-- default enable check (rather than replacing it) so its existing
			-- validity/filetype checks still apply.
			local dropbar_configs = require("dropbar.configs")
			local default_enable = dropbar_configs.opts.bar.enable
			opts.bar.enable = function(buf, win, info)
				if default_enable(buf, win, info) == false then
					return false
				end
				return not require("config.bigbuf").is_large(buf)
			end
			require("dropbar").setup(opts)
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick symbol in breadcrumbs" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next breadcrumb context" })
		end,
	},

	-- Markdown Preview
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {
			checkbox = {
				custom = {
					cancelled = { raw = "[~]", rendered = "󰜺 ", highlight = "DiagnosticError", scope_highlight = "Comment" },
					important = { raw = "[!]", rendered = "󰀦 ", highlight = "DiagnosticWarn" },
					forwarded = { raw = "[>]", rendered = "󰑃 ", highlight = "RenderMarkdownTodo" },
				},
			},
		},
	},

	-- Line Justice (Dual Absolute & Relative Line Numbers)
	{
		"zaakiy/line-justice.nvim",
		dependencies = {
			"luukvbaal/statuscol.nvim",
			"lewis6991/gitsigns.nvim",
		},
		lazy = false,
		config = function()
			local lj = require("line-justice")
			lj.setup()

			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
					{
						sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, auto = true },
						click = "v:lua.ScSa",
					},
					{ sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true }, click = "v:lua.ScSa" },
					{
						sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
						click = "v:lua.ScSa",
					},
					{ text = { lj.segment }, click = "v:lua.ScLa" },
				},
			})
		end,
	},

	-- Code Biscuits (Treesitter Context Annotations)
	{
		"code-biscuits/nvim-biscuits",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		event = "BufRead",
		config = function()
			require("nvim-biscuits").setup({
				cursor_line_only = true,
				default_config = {
					max_length = 60, -- Max characters for the virtual text
					min_distance = 5, -- Only show biscuit if the block is at least this many lines long
					prefix_string = " 󰊠 ", -- Adds a nice icon before the biscuit text
					show_on_start = true,
				},
			})
			-- Turn down opacity by linking to the much dimmer 'LspInlayHint' or 'NonText' highlight group
			vim.api.nvim_set_hl(0, "BiscuitColor", { link = "LspInlayHint" })

			-- PATCH: Fix nvim-biscuits showing the wrong line for Go functions by ignoring internal blocks
			local langs = require("nvim-biscuits.languages")
			local orig_should_decorate = langs.should_decorate
			langs.should_decorate = function(language_name, ts_node, text, bufnr)
				-- Mostly prose, not code -- the end-of-block hints aren't useful there.
				if vim.bo[bufnr].filetype == "markdown" then
					return false
				end
				if language_name == "go" then
					local type = ts_node:type()
					if type == "block" or type == "statement_list" then
						return false
					end
				end
				return orig_should_decorate(language_name, ts_node, text, bufnr)
			end

			-- PATCH: with cursor_line_only, nvim-biscuits runs its (treesitter-heavy)
			-- decorate_nodes synchronously on every single CursorMoved/CursorMovedI
			-- event, unthrottled. Holding a movement key floods it with calls faster
			-- than it can keep up, backing up the input queue (shows up as lag and
			-- the cursor still moving after you let go of the key). Debounce it so
			-- it only actually renders ~80ms after the cursor settles, and skip it
			-- entirely on large buffers where even the debounced walk adds up.
			local biscuits = require("nvim-biscuits")
			local orig_decorate_nodes = biscuits.decorate_nodes
			local debounce_timer
			biscuits.decorate_nodes = function(bufnr, parser_lang)
				if require("config.bigbuf").is_large(bufnr) then
					return
				end
				if debounce_timer then
					debounce_timer:stop()
					debounce_timer:close()
				end
				debounce_timer = vim.uv.new_timer()
				debounce_timer:start(
					80,
					0,
					vim.schedule_wrap(function()
						orig_decorate_nodes(bufnr, parser_lang)
						if debounce_timer then
							debounce_timer:close()
							debounce_timer = nil
						end
					end)
				)
			end
		end,
	},
}

