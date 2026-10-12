return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- Runs at startup (the plugin itself is lazy-loaded) so Home.md's links are
    -- regenerated whenever it's opened.
    init = function()
      require("config.notes_home").setup()
    end,
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/Documents/notes",
        },
      },
      finder = "fzf-lua",
      completion = {
        blink = true,
        nvim_cmp = false,
        min_chars = 2,
      },
      -- New notes land in inbox/ and get triaged during the weekly review.
      notes_subdir = "inbox",
      new_notes_location = "notes_subdir",
      -- Name new notes after their title in kebab-case ("Fraud Skill" -> fraud-skill.md)
      -- instead of the default timestamp ID.
      note_id_func = function(title)
        if title == nil or title == "" then
          return tostring(os.date("%Y-%m-%d-%H%M%S"))
        end
        return (title:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", ""))
      end,
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      daily_notes = {
        folder = "daily notes",
        template = "daily.md",
      },
      attachments = {
        img_folder = "images",
      },
      follow_url_func = function(url)
        vim.ui.open(url)
      end,
      follow_img_func = function(img)
        vim.ui.open(img)
      end,
      -- render-markdown.nvim already handles conceal/highlighting
      ui = {
        enable = false,
        checkboxes = {
          [" "] = { order = 1 },
          ["x"] = { order = 2 },
          ["~"] = { order = 3 },
          ["!"] = { order = 4 },
          [">"] = { order = 5 },
        },
      },
    },
    keys = {
      { "<leader>nh", function() require("config.notes_home").open() end, desc = "Notes home" },
      { "<leader>no", "<cmd>ObsidianOpen<cr>", desc = "Open current note in Obsidian app" },
      { "<leader>nf", "<cmd>ObsidianQuickSwitch<cr>", desc = "Find note" },
      { "<leader>ns", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
      { "<leader>nb", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
      { "<leader>nl", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link under cursor" },
      { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "New note" },
      { "<leader>nT", "<cmd>ObsidianNewFromTemplate<cr>", desc = "New note from template" },
      { "<leader>nd", "<cmd>ObsidianToday<cr>", desc = "Open today's daily note" },
      { "<leader>nr", "<cmd>ObsidianRename<cr>", desc = "Rename note (updates backlinks)" },
      { "<leader>nc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
      { "<leader>np", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image" },
      { "<leader>nt", "<cmd>ObsidianTags<cr>", desc = "Browse tags" },
      { "<leader>nk", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Link selection to note" },
      { "<leader>nK", "<cmd>ObsidianLinkNew<cr>", mode = "v", desc = "Link selection to new note" },
    },
  },
}
