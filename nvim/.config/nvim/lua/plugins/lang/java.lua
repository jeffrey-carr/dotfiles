return {
  -- JDTLS for Java support
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local config = {
        cmd = { 'jdtls' },
        root_dir = vim.fs.dirname(vim.fs.find({'.git', 'mvnw', 'gradlew'}, { upward = true })[1]),
      }
      require('jdtls').start_or_attach(config)
    end,
  },

  -- Ensure Mason installs jdtls
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "jdtls" })
    end,
  },

  -- Reserve the server name in lspconfig but skip auto-setup
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {}
      }
    }
  }
}