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
      local blink = require('blink.cmp')

      for server, server_opts in pairs(opts.servers or {}) do
        server_opts.capabilities = blink.get_lsp_capabilities(server_opts.capabilities)
        vim.lsp.config(server, server_opts)
      end
      vim.lsp.enable(vim.tbl_keys(opts.servers or {}))

      -- Add rounded borders to diagnostic float windows as well
      vim.diagnostic.config({
        float = { border = "rounded" },
      })

      -- Global mappings.
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
      -- Noice reassigns vim.lsp.buf.hover to its own renderer once it loads
      -- (on VeryLazy, after this runs) -- look it up at call time, not here,
      -- so the keymap picks up Noice's version instead of the vanilla one.
      vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = 'Hover Documentation' })
      vim.keymap.set('n', '<leader>rs', vim.lsp.buf.rename, { desc = 'Rename symbol' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })

      -- Detach any client that attaches to a buffer that isn't a real file
      -- on disk (diffview://, fugitive://, etc.). General safety net for any
      -- language server; see lua/plugins/lang/go.lua for gopls's root_dir
      -- guard, which prevents attachment (and the initial didOpen) entirely.
      -- Also enable inlay hints for any client that supports them (e.g.
      -- gopls, vtsls, pyright).
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local lsp_util = require("config.lsp_util")
          if lsp_util.is_non_file_buf(args.buf) then
            lsp_util.detach_deferred(args.buf, args.data.client_id)
            return
          end

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
      vim.keymap.set('n', '<leader>uh', function()
        require("config.lsp_util").toggle_gopls_full_hints(0)
      end, { desc = 'Toggle full gopls inlay hints' })
    end
  }
}