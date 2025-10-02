return {
  "folke/snacks.nvim",
  opts = {
    picker = { sources = { explorer = { hidden = true } } },
    explorer = {},
  },
  keys = {
    {
      --find files in obsidian folder "find in obsidian"
      "<leader>fin",
      function()
        Snacks.picker.files({ cwd = "~/iawriter/" })
      end,
    },
    {
      --grep obsidian folder "grep in obsidian"
      "<leader>gin",
      function()
        Snacks.picker.grep({ cwd = "~/iawriter/" })
      end,
    },
    {
      --find files in blog folder "find in blog"
      "<leader>fib",
      function()
        Snacks.picker.files({ cwd = "~/Documents/programming/projects/lukemelnik.co/" })
      end,
    },
    {
      --grep blog folder "grep in blog"
      "<leader>gib",
      function()
        Snacks.picker.grep({ cwd = "~/Documents/programming/projects/lukemelnik.co/" })
      end,
    },
    {
      --find files in config folder "find in config"
      "<leader>fic",
      function()
        Snacks.picker.files({ cwd = "~/.config" })
      end,
    },
    {
      --grep config folder "grep in config"
      "<leader>gic",
      function()
        Snacks.picker.grep({ cwd = "~/.config" })
      end,
    },
  },
}
