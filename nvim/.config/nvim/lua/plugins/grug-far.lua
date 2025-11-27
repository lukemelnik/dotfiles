return {
  "MagicDuck/grug-far.nvim",
  config = function()
    require("grug-far").setup({})

    -- Keymaps
    -- srf: search/replace in current file
    vim.keymap.set("n", "sf", function()
      require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
    end, { desc = "Search and replace in current file" })
  end,
}
