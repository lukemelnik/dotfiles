return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
  },
}