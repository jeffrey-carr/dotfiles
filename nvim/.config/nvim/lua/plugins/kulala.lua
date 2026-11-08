return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  -- Registered early so the session save/restore hooks are in place.
  event = { "SessionLoadPost", "VimLeavePre" },
  keys = {
    -- Open a throwaway buffer, pre-seeded with an example request
    { "<leader>rn", function() require("kulala").scratchpad() end, desc = "REST scratchpad" },
    -- Run the request under the cursor
    { "<leader>rr", function() require("kulala").run() end, desc = "Run REST request" },
    -- Re-open the response window without re-sending the request
    { "<leader>ro", function() require("kulala").open() end, desc = "Open REST response" },
    -- Re-run the last request
    { "<leader>rl", function() require("kulala").replay() end, desc = "Replay last REST request" },
  },
  opts = {
    ui = {
      win_opts = {
        -- The response window folds by indent; keep it fully open by default.
        wo = { foldlevel = 99 },
      },
    },
  },
}
