return {
  "rest-nvim/rest.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    -- Open a temporary, throwaway buffer for quick requests
    { "<leader>rn", "<cmd>vnew | setlocal buftype=nofile bufhidden=wipe noswapfile filetype=http<cr>", desc = "New REST scratch buffer" },
    -- Run the request under the cursor
    { "<leader>rr", "<cmd>Rest run<cr>", desc = "Run REST request" },
    -- Re-run the last request
    { "<leader>rl", "<cmd>Rest last<cr>", desc = "Run last REST request" },
  },
}
