return {
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "AlexvZyl/nordic.nvim", name = "nordic", lazy = true },
  { "sainnhe/everforest", name = "everforest", lazy = true },
  { "EdenEast/nightfox.nvim", name = "nightfox", lazy = true },
  { "scottmckendry/cyberdream.nvim", name = "cyberdream", lazy = true },
  { "eldritch-theme/eldritch.nvim", name = "eldritch", lazy = true },
  { "rmehri01/onenord.nvim", name = "onenord", lazy = true },
  { "loctvl842/monokai-pro.nvim", name = "monokai-pro", lazy = true },
  { "maxmx03/fluoromachine.nvim", name = "fluoromachine", lazy = true },

  {
    "brianmargolis/shades.nvim",
    name = "shades",
    lazy = false,
    event = "VimEnter",
    config = function()
      -- Setup theme configurations
      require("catppuccin").setup({
        integrations = {
          cmp = true, gitsigns = true, nvimtree = true, treesitter = true,
          notify = false, mini = { enabled = true },
        },
      })

      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "main",
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
      })

      require("cyberdream").setup({
        transparent = false,
        italic_comments = true,
      })

      require("eldritch").setup({
        transparent = false,
      })

      require("onenord").setup({
      })

      require("monokai-pro").setup({
        filter = "pro",
      })

      local shades = require("shades")
      shades.set_color = function(theme)
        -- theme is "themeName;variantName" (e.g. "rose-pine;dawn")
        local parts = vim.split(theme, ";")
        local theme_name = parts[1]
        local variant_name = parts[2] or ""

        -- Determine background style
        local is_light = variant_name:find("light") or variant_name:find("dawn") or variant_name:find("latte")
        vim.opt.background = is_light and "light" or "dark"

        -- Apply colorscheme
        if theme_name == "rose-pine" then
          if variant_name == "dawn" then
            vim.cmd.colorscheme "rose-pine-dawn"
          elseif variant_name == "moon" then
            vim.cmd.colorscheme "rose-pine-moon"
          else
            vim.cmd.colorscheme "rose-pine"
          end
        elseif theme_name == "catppuccin" then
          if variant_name == "latte" then
            vim.cmd.colorscheme "catppuccin-latte"
          elseif variant_name == "mocha" then
            vim.cmd.colorscheme "catppuccin-mocha"
          else
            vim.cmd.colorscheme "catppuccin"
          end
        elseif theme_name == "nordic" then
          vim.cmd.colorscheme "nordic"
        elseif theme_name == "everforest" then
          vim.g.everforest_background = "medium"
          vim.cmd.colorscheme "everforest"
        elseif theme_name == "nightfox" then
          if variant_name == "dawn" or variant_name == "light" then
            vim.cmd.colorscheme "dawnfox"
          else
            vim.cmd.colorscheme "nightfox"
          end
        elseif theme_name == "cyberdream" then
          vim.cmd.colorscheme "cyberdream"
        elseif theme_name == "eldritch" then
          if variant_name == "darker" then
            vim.cmd.colorscheme "eldritch-dark"
          elseif variant_name == "minimal" then
            vim.cmd.colorscheme "eldritch-minimal"
          else
            vim.cmd.colorscheme "eldritch"
          end
        elseif theme_name == "onenord" then
          vim.cmd.colorscheme "onenord"
        elseif theme_name == "monokai-pro" then
          local filter = "pro"
          if variant_name == "classic" or variant_name == "machine" or variant_name == "octagon" or variant_name == "ristretto" or variant_name == "spectrum" or variant_name == "light" then
            filter = variant_name
          end
          require("monokai-pro").setup({
            filter = filter,
          })
          vim.cmd.colorscheme "monokai-pro"
        elseif theme_name == "fluoromachine" then
          local fm_theme = "fluoromachine"
          if variant_name == "retrowave" or variant_name == "delta" or variant_name == "cyberpunk" then
            fm_theme = variant_name
          end
          require("fluoromachine").setup({
            theme = fm_theme,
            glow = true,
          })
          vim.cmd.colorscheme "fluoromachine"
        else
          pcall(vim.cmd.colorscheme, theme_name)
        end
      end
      shades.listen()
    end,
  },
}