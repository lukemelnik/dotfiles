-- return {
--   {
--     "folke/tokyonight.nvim",
--     lazy = true,
--     opts = { transparent = true, styles = { sidebars = "transparent", floats = "transparent" }, style = "night" },
--   },
-- }
--
-- return {
--   "rebelot/kanagawa.nvim",
--   opts = {
--     transparent = true,
--     colors = {
--       theme = {
--         all = {
--           ui = {
--             bg_gutter = "none",
--           },
--         },
--       },
--     },
--   },
-- }
--
--  This is the function style to initiate the colorscheme on load
return {
  "rebelot/kanagawa.nvim",
  -- this is to get rid of the weird dark boxes in status bar
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "kanagawa",
      callback = function()
        vim.api.nvim_set_hl(0, "StatusLine", { link = "lualine_c_normal" })
      end,
    })
  end,
  config = function()
    require("kanagawa").setup({
      compile = true,
      transparent = true,
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- Transparent backgrounds for floating windows and sidebars
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          NormalNC = { bg = "none" },
          MsgArea = { bg = "none" },
          NeoTreeNormal = { bg = "none" },
          NeoTreeNormalNC = { bg = "none" },
          Pmenu = { bg = "none" },
          PmenuSbar = { bg = "none" },
          PmenuSel = { bg = theme.ui.bg_p2 },
          PmenuThumb = { bg = "none" },
          TelescopeNormal = { bg = "none" },
          TelescopeBorder = { bg = "none" },
        }
      end,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
    })
    vim.cmd("colorscheme kanagawa")
  end,
  build = function()
    vim.cmd("KanagawaCompile")
  end,
}
