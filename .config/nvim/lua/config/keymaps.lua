-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "<leader>df", function()
  local file = vim.fn.expand("%")
  if vim.fn.confirm("Delete file: " .. file .. "?", "&Yes\n&No", 2) == 1 then
    vim.fn.delete(file)
    vim.cmd("bdelete!")
    print("Deleted: " .. file)
  end
end, { desc = "Delete current file" })
