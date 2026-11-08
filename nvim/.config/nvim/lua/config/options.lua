-- Core options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.synmaxcol = 240
-- Noice's cmdline popup takes over the native command-line row, so the built-in
-- showcmd indicator has nowhere to draw. Route it through the statusline (%S)
-- instead -- see the lualine component in plugins/ui.lua.
vim.opt.showcmdloc = "statusline"
-- tmux answers each synchronized-update block from nvim by repainting the whole
-- pane, so holding j sent ~37MB/9s to the terminal (vs ~1MB without) and the
-- display fell seconds behind. Ghostty on its own handles termsync fine.
if vim.env.TMUX then
  vim.opt.termsync = false
end

-- Mostly prose there -- spellcheck helps, elsewhere it'd just flag identifiers.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    -- Wide tables and long URLs scroll sideways instead of wrapping, which would
    -- misalign render-markdown's table border overlays.
    vim.opt_local.wrap = false
  end,
})
