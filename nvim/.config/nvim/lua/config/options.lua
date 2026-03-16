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

-- Determine user environment based on git email
local git_email = vim.fn.system('git config --get user.email'):gsub('%s+', '')
local is_home = git_email == 'jeffrey.carr98@gmail.com'
local is_work = git_email == 'jeff@getredcircle.com'

-- Store profile information globally so plugins can access it conditionally
_G.jeff_profile = {
  is_home = is_home,
  is_work = is_work,
}

-- Trigger notification on startup about the environment
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if is_work then
      vim.notify("Logged in as work.")
    elseif is_home then
      vim.notify("Logged in as home. Happy coding :)")
    else
      vim.notify("Not logged in. AI agents disabled")
    end
  end,
})
