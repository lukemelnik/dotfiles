return {
  "folke/snacks.nvim",
  opts = {
    styles = {
      zen = {
        width = 80,
      },
    },
    bigfile = { enabled = true },
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = false,
        float = true,
      },
    },
    picker = {
      matcher = {
        frecency = true,
      },
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["d"] = "explorer_del",
              },
            },
          },
        },
      },
    },
    zen = {
      toggles = {
        diagnostics = false, -- hide LSP diagnostics
        inlay_hints = false, -- hide inline LSP hints
        line_number = false,
        indent = false,
        dim = true,
        git_signs = false,
        sign_column = "no",
      },
      on_open = function(win)
        -- turn off numbers
        vim.wo[win.win].number = false
        vim.wo[win.win].relativenumber = false

        -- restrict completion sources for writing
        local ok, cmp = pcall(require, "cmp")
        if ok then
          local lsp_kinds = cmp.lsp.CompletionItemKind
          cmp.setup.buffer({
            sources = {
              { name = "luasnip" },
              { name = "buffer" },
              { name = "path" },
              {
                name = "nvim_lsp",
                entry_filter = function(entry, _)
                  local kind = entry:get_kind()
                  -- keep only text/keywords from LSP
                  return kind == lsp_kinds.Text or kind == lsp_kinds.Keyword
                end,
              },
            },
          })
        end
      end,

      on_close = function(win)
        -- restore numbers
        vim.wo[win.win].number = true
        vim.wo[win.win].relativenumber = true

        -- restore normal cmp config
        local ok, cmp = pcall(require, "cmp")
        if ok then
          cmp.setup.buffer({ sources = cmp.config.sources() })
        end
      end,
    },
  },
}
