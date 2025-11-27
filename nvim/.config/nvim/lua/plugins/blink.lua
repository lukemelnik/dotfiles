return {
  "saghen/blink.cmp",
  dependencies = {
    "moyiz/blink-emoji.nvim",
    "Kaiser-Yang/blink-cmp-dictionary",
  },
  opts = {
    keymap = {
      preset = "default",
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
    },
    cmdline = { enabled = true },
    -- enabled = function()
    --   return not vim.tbl_contains({ "markdown" }, vim.bo.filetype)
    -- end,
    sources = {
      default = { "emoji", "dadbod" },
      providers = {
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
          score_offset = 95,
        },
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
          opts = { insert = true }, -- Insert emoji (default) or complete its name
          should_show_items = function()
            return vim.tbl_contains(
              -- Enable emoji completion only for git commits and markdown.
              -- By default, enabled for all file-types.
              { "gitcommit", "markdown" },
              vim.o.filetype
            )
          end,
        },
      },
    },
  },
}
