return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = { enabled = true },
      },
    },
  },
  { "folke/tokyonight.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {
      variant = "auto",
      dark_variant = "main",
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
    },
  },
  { "AlexvZyl/nordic.nvim", name = "nordic", lazy = true },
  { "sainnhe/everforest", name = "everforest", lazy = true },
  { "EdenEast/nightfox.nvim", name = "nightfox", lazy = true },
  {
    "scottmckendry/cyberdream.nvim",
    name = "cyberdream",
    lazy = true,
    opts = {
      transparent = false,
      italic_comments = true,
    },
  },
  {
    "eldritch-theme/eldritch.nvim",
    name = "eldritch",
    lazy = true,
    opts = {
      transparent = false,
    },
  },
  { "rmehri01/onenord.nvim", name = "onenord", lazy = true },
  {
    "loctvl842/monokai-pro.nvim",
    name = "monokai-pro",
    lazy = true,
    opts = {
      filter = "pro",
    },
  },
  { "maxmx03/fluoromachine.nvim", name = "fluoromachine", lazy = true },
  { "Verf/deepwhite.nvim", name = "deepwhite", lazy = true },
  { "yorik1984/newpaper.nvim", name = "newpaper", lazy = true },
  { "embark-theme/vim", name = "embark", lazy = true },
  { "datsfilipe/vesper.nvim", name = "vesper", lazy = true },
  { "shaunsingh/moonlight.nvim", name = "moonlight", lazy = true },
  { "lewpoly/sherbet.nvim", name = "sherbet", lazy = true },
  { "nvimdev/zephyr-nvim", name = "zephyr", lazy = true },
  { "mellow-theme/mellow.nvim", name = "mellow", lazy = true },
  { "tiagovla/tokyodark.nvim", name = "tokyodark", lazy = true },

  {
    "brianmargolis/shades.nvim",
    name = "shades",
    lazy = false,
    config = function()
      local shades = require("shades")
      shades.set_color = function(theme)
        -- theme is "themeName;variantName" (e.g. "rose-pine;dawn")
        local parts = vim.split(theme, ";")
        local theme_name = parts[1]
        local variant_name = parts[2] or ""

        -- Determine background style
        local is_light = variant_name:find("light") or variant_name:find("dawn") or variant_name:find("latte") or theme_name == "deepwhite" or theme_name == "newpaper"
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
        elseif theme_name == "deepwhite" then
          vim.cmd.colorscheme "deepwhite"
        elseif theme_name == "newpaper" then
          local style_val = (variant_name == "dark") and "dark" or "light"
          require("newpaper").setup({ style = style_val })
          vim.cmd.colorscheme "newpaper"
        elseif theme_name == "embark" then
          vim.cmd.colorscheme "embark"
        elseif theme_name == "vesper" then
          vim.cmd.colorscheme "vesper"
        elseif theme_name == "moonlight" then
          vim.cmd.colorscheme "moonlight"
        elseif theme_name == "sherbet" then
          vim.cmd.colorscheme "sherbet"
        elseif theme_name == "zephyr" then
          vim.cmd.colorscheme "zephyr"
        elseif theme_name == "mellow" then
          vim.g.mellow_variant = (variant_name == "light") and "light" or "dark"
          vim.cmd.colorscheme "mellow"
        elseif theme_name == "tokyodark" then
          vim.cmd.colorscheme "tokyodark"
        else
          pcall(vim.cmd.colorscheme, theme_name)
        end
      end

      -- Synchronously fetch current shades theme on startup to prevent flicker
      local socket_path = "/tmp/theme-change.sock"
      local sock_exists = vim.loop.fs_stat(socket_path)
      if sock_exists and sock_exists.type == "socket" then
        local theme_raw = vim.fn.system("echo 'get:' | nc -U -w 1 /tmp/theme-change.sock 2>/dev/null")
        if vim.v.shell_error == 0 and theme_raw and theme_raw ~= "" then
          local theme = theme_raw:gsub("%s+", ""):match("^set:(.+)$")
          if theme then
            shades.set_color(theme)
            shades.current_theme = theme
          end
        end
      end

      shades.listen()
    end,
  },
}