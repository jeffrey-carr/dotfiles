local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Set mapleader before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "plugins.lang" },
  },
  defaults = {
    -- Plugins load during startup unless their spec opts into lazy loading.
    lazy = false,
  },
  -- No plugin here needs LuaRocks; keep lazy.nvim from bootstrapping hererocks
  -- when some plugin happens to ship a rockspec.
  rocks = { enabled = false },
  checker = { enabled = false }, -- automatically check for plugin updates
  change_detection = {
    enabled = false,
    notify = false,
  },
  })