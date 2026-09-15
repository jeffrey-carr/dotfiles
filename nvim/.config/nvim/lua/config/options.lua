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

-- Determine user environment based on git email
local git_email = vim.fn.system('git config --get user.email'):gsub('%s+', '')
local is_home = git_email == 'jeffrey.carr98@gmail.com'
local is_work = git_email == 'jeff@getredcircle.com'

-- Mostly prose there -- spellcheck helps, elsewhere it'd just flag identifiers.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Store profile information globally so plugins can access it conditionally
_G.jeff_profile = {
  is_home = is_home,
  is_work = is_work,
}
