-- Core keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ported leap window keybind from old_plugin_manager
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

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
vim.keymap.set("n", "<leader>x", "<cmd>x<cr>", { desc = "Save and Quit" })
