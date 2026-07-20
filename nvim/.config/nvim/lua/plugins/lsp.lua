return {
  -- Mason for managing external tools
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "prettierd",
        "goimports",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Mason-lspconfig for bridging mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "lua_ls" },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              completion = { callSnippet = "Replace" },
            },
          },
        },
      },
    },
    config = function(_, opts)
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      -- Use the configs module directly to avoid the deprecated framework warnings
      -- and the __index recursion issues in Neovim 0.11
      local configs = require("lspconfig.configs")

      for server, server_opts in pairs(opts.servers or {}) do
        local config = configs[server]
        if config then
          server_opts.capabilities = require("blink.cmp").get_lsp_capabilities(server_opts.capabilities)
          config.setup(server_opts)
        end
      end

      -- Customize LSP floating window appearance (borders & padding)
      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        config = config or {}
        config.border = "rounded"
        local float_bufnr, float_winid = vim.lsp.handlers.hover(err, result, ctx, config)

        if float_bufnr and vim.api.nvim_buf_is_valid(float_bufnr) then
          local orig_bufnr = ctx.bufnr
          local orig_winnr = vim.fn.bufwinid(orig_bufnr)

          local function close_and_run(fn)
            return function()
              if vim.api.nvim_win_is_valid(float_winid) then
                vim.api.nvim_win_close(float_winid, true)
              end
              if orig_winnr ~= -1 and vim.api.nvim_win_is_valid(orig_winnr) then
                vim.api.nvim_set_current_win(orig_winnr)
              end
              fn()
            end
          end

          local opts = { buffer = float_bufnr, silent = true }
          vim.keymap.set('n', 'gd', close_and_run(vim.lsp.buf.definition),
            vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
          vim.keymap.set('n', 'gr', close_and_run(vim.lsp.buf.references),
            vim.tbl_extend('force', opts, { desc = 'Go to references' }))
          vim.keymap.set('n', 'gi', close_and_run(vim.lsp.buf.implementation),
            vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
          vim.keymap.set('n', '<leader>fd', close_and_run(function() vim.cmd('FzfLua lsp_definitions') end),
            vim.tbl_extend('force', opts, { desc = 'Find definitions' }))
          vim.keymap.set('n', '<leader>fr', close_and_run(function() vim.cmd('FzfLua lsp_references') end),
            vim.tbl_extend('force', opts, { desc = 'Find references' }))
          vim.keymap.set('n', '<leader>fi', close_and_run(function() vim.cmd('FzfLua lsp_implementations') end),
            vim.tbl_extend('force', opts, { desc = 'Find implementations' }))
        end

        return float_bufnr, float_winid
      end

      vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
        config = config or {}
        config.border = "rounded"
        return vim.lsp.handlers.signature_help(err, result, ctx, config)
      end

      -- Add rounded borders to diagnostic float windows as well
      vim.diagnostic.config({
        float = { border = "rounded" },
      })

      -- Global mappings.
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
      vim.keymap.set('n', 'K', function()
        vim.lsp.buf.hover({ border = "rounded" })
      end, { desc = 'Hover Documentation' })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
    end
  }
}