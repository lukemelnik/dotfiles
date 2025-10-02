return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {},
        tsserver = {
          enabled = false,
        },
        vtsls = {
          enabled = false,
        },
      },
      setup = {
        biome = function(_, opts)
          local lspconfig = require("lspconfig")
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.general = capabilities.general or {}
          capabilities.general.positionEncodings = { "utf-16", "utf-8" }

          opts.capabilities = vim.tbl_deep_extend("force", opts.capabilities or {}, capabilities)

          lspconfig.biome.setup(opts)
          return true
        end,
      },
    },
  },
}
