-- Core keymaps
-- (mapleader is set in config.lazy before plugins load)

-- Remove search highlights
vim.keymap.set("n", "<leader>rh", "<cmd>:noh<CR>", { desc = "Remove search highlights" })

-- Splits
vim.keymap.set("n", "<leader>s", "<cmd>vsplit<cr>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split horizontally" })

-- Split Navigation (Ctrl-hjkl)
-- Ensure 'remap = true' isn't needed, but map both BS and C-h just in case terminal sends BS.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<BS>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Useful default mappings
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Buffers
vim.keymap.set("n", "<leader>cb", function()
	Snacks.bufdelete()
end, { desc = "Close buffer" })
vim.keymap.set("n", "<Tab>",       "<Plug>(cokeline-focus-next)",  { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>",     "<Plug>(cokeline-focus-prev)",  { silent = true, desc = "Prev buffer" })
vim.keymap.set("n", "[b",          "<Plug>(cokeline-focus-prev)",  { desc = "Prev buffer" })
vim.keymap.set("n", "]b",          "<Plug>(cokeline-focus-next)",  { desc = "Next buffer" })
vim.keymap.set("n", "[B",          "<Plug>(cokeline-switch-prev)", { desc = "Move buffer left" })
vim.keymap.set("n", "]B",          "<Plug>(cokeline-switch-next)", { desc = "Move buffer right" })
vim.keymap.set("n", "<leader>bp",  "<Plug>(cokeline-pick-focus)",  { desc = "Buffer pick" })
vim.keymap.set("n", "<leader>bo", function()
	local cur = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= cur and vim.bo[buf].buflisted then
			vim.api.nvim_buf_delete(buf, { force = false })
		end
	end
end, { desc = "Close other buffers" })

-- Terminal
vim.keymap.set({ "n", "t" }, "<leader>ot", "<cmd>ToggleTerm<cr>", { desc = "Toggle bottom terminal" })
vim.keymap.set({ "n", "t" }, "<leader>of", "<cmd>ToggleTerm direction=float<cr>", { desc = "Toggle floating terminal" })
vim.keymap.set({ "n", "t" }, "<leader>ov", "<cmd>ToggleTerm direction=vertical size=60<cr>", { desc = "Toggle vertical terminal" })
vim.keymap.set({ "n", "t" }, "<leader>oh", "<cmd>ToggleTerm direction=horizontal size=20<cr>", { desc = "Toggle horizontal terminal" })

-- Git
local function copy_github_permalink()
	-- Get absolute path to current file
	local file = vim.fn.expand("%:p")
	local line = vim.fn.line(".")

	-- Get Git info
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	local repo = vim.fn
		.system("git config --get remote.origin.url")
		:gsub("%.git\n", "")
		:gsub("git@github.com:", "https://github.com/")
		:gsub("\n", "")
	local commit = vim.fn.system("git rev-parse HEAD"):gsub("\n", "")

	-- Relative path from Git root
	local rel_path = file:sub(#git_root + 2) -- +2 to account for trailing slash

	-- Construct URL
	local url = string.format("%s/blob/%s/%s#L%d", repo, commit, rel_path, line)

	-- Copy to clipboard
	vim.fn.setreg("+", url)
	vim.notify("📎 Copied remote link to clipboard", vim.log.levels.INFO)
end
vim.keymap.set("n", "<leader>rc", copy_github_permalink, { desc = "Copy GitHub permalink" })
