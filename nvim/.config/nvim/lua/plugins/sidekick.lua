return {
  "folke/sidekick.nvim",
  opts = {
    -- add any options here
    cli = {
      -- win = {
      --   layout = "float",
      -- },
      mux = {
        backend = "tmux",
        enabled = false,
      },
    },
  },
}
