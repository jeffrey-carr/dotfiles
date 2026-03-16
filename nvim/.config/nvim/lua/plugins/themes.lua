return {
  -- Theme Profile Loader
  -- This plugin reads the global theme state and applies the current theme profile.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      -- 1. Read Mode (dark/light)
      local state_file = vim.fn.expand("~/.config/theme/theme_state")
      local mode = "dark"
      local f_state = io.open(state_file, "r")
      if f_state then
        mode = f_state:read("*l") or "dark"
        f_state:close()
      end

      -- 2. Read Active Profile
      local config_file = vim.fn.expand("~/.config/theme/theme_config")
      local profile_name = (mode == "light") and "catppuccin-latte" or "catppuccin-mocha"
      local f_config = io.open(config_file, "r")
      if f_config then
        for line in f_config:lines() do
          local p = line:match(mode .. "_profile=\"(.+)\"")
          if p then profile_name = p end
        end
        f_config:close()
      end

      -- 3. Load Profile Settings
      local profile_file = vim.fn.expand("~/.config/theme/profiles/" .. profile_name .. ".sh")
      local profile = { 
        theme = "catppuccin",
        flavor = (mode == "light") and "latte" or "mocha" 
      }
      local f_prof = io.open(profile_file, "r")
      if f_prof then
        for line in f_prof:lines() do
          local theme = line:match("NVIM_THEME=\"(.+)\"")
          if theme then profile.theme = theme end
          local flavor = line:match("NVIM_FLAVOR=\"(.+)\"")
          if flavor then profile.flavor = flavor end
        end
        f_prof:close()
      end

      -- 4. Setup Themes
      require("catppuccin").setup({
        flavour = profile.flavor,
        integrations = {
          cmp = true, gitsigns = true, nvimtree = true, treesitter = true,
          notify = false, mini = { enabled = true },
        },
      })

      require("tokyonight").setup({ style = "storm" })
      
      require("kanagawa").setup({
        theme = "wave",
        background = { dark = "wave", light = "lotte" }
      })

      require("rose-pine").setup({
        variant = "auto", -- auto, main, moon, or dawn
        dark_variant = "main", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
      })

      -- 5. Apply
      vim.opt.background = (mode == "light") and "light" or "dark"
      
      -- Special handling for flavor-based themes
      if profile.theme == "catppuccin" then
        vim.cmd.colorscheme "catppuccin"
      elseif profile.theme == "rose-pine" then
        if profile.flavor == "dawn" then
          vim.cmd.colorscheme "rose-pine-dawn"
        elseif profile.flavor == "moon" then
          vim.cmd.colorscheme "rose-pine-moon"
        else
          vim.cmd.colorscheme "rose-pine"
        end
      else
        vim.cmd.colorscheme(profile.theme)
      end
    end,
  },

  -- Theme Plugins
  { "folke/tokyonight.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
}