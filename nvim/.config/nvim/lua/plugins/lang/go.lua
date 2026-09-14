return {
  -- Update Mason with Go LSP
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gopls" })
    end,
  },

  -- Setup Go LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- Prevent gopls from attaching to diffview:// and fugitive:// buffers
          single_file_support = false,
          root_dir = function(fname)
            if fname:match("^diffview://") or fname:match("^fugitive://") then
              return nil
            end
            local util = require("lspconfig.util")
            return util.root_pattern("go.work", "go.mod", ".git")(fname)
          end,
          on_init = function(client)
            local original_notify = client.notify
            client.notify = function(method, params)
              if params and params.textDocument and params.textDocument.uri and params.textDocument.uri:match("^diffview://") then
                return true
              end
              return original_notify(method, params)
            end

            local original_request = client.request
            client.request = function(method, params, handler, bufnr)
              if params and params.textDocument and params.textDocument.uri and params.textDocument.uri:match("^diffview://") then
                return true, 1
              end
              return original_request(method, params, handler, bufnr)
            end
          end,
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = false,
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = false,
              },
            },
          },
        }
      }
    }
  },

  -- Gopher (Go development utilities)
  {
    "olexsmir/gopher.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("gopher").setup({
        gotag = {
          transform = "camelcase",
        },
      })
    end,
    keys = {
      { "<leader>gsj", "<cmd>GoTagAdd json<cr>", desc = "Add json struct tags" },
      { "<leader>gsy", "<cmd>GoTagAdd yaml<cr>", desc = "Add yaml struct tags" },
    }
  },

  -- Neotest (Highly integrated test runner replacing older tools)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Go specific adapter with testify suite support
      {
        "fredrikaverpil/neotest-golang",
        build = function()
          vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
        end,
      },
    },
    config = function()
      require("neotest").setup({
        discovery = {
          enabled = false,
        },
        diagnostic = {
          enabled = true,
          min_level = vim.log.levels.ERROR,
        },
        summary = {
          follow_test = true,
          open = "botright vsplit | vertical resize 40",
        },
        consumers = {
          auto_summary = function(client)
            client.listeners.run = function()
              require("neotest").summary.open()
            end
            return {}
          end,
        },
        adapters = {
          require("neotest-golang")({
            runner = "gotestsum",
            gotestsum_args = { "--format", "standard-verbose" },
            go_test_args = { "-v", "-count=1", "-timeout=60s" },
            testify_enabled = true,
          })
        }
      })
    end,
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%:p")) end, desc = "Run file tests" },
      { "<leader>td", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run all tests" },
      { "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle test output panel" },
      { "<leader>tO", function() require("neotest").output.open({ enter = true, short = true }) end, desc = "Show test failure (short)" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>tn", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Jump to next failure" },
      { "<leader>tp", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Jump to prev failure" },
    }
  }
}