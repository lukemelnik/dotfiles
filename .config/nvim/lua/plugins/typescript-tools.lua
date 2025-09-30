return {
  -- Add typescript-tools.nvim
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      settings = {
        -- Performance optimizations for monorepo
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",

        -- Memory limit - adjust based on your project size
        tsserver_max_memory = "auto",

        -- Useful code actions
        expose_as_code_action = {
          "fix_all",
          "add_missing_imports",
          "remove_unused",
          "organize_imports",
        },

        -- Enhanced completions
        complete_function_calls = true,
        include_completions_with_insert_text = true,

        -- JSX auto-close tag
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" },
        },

        -- File preferences
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
          includeCompletionsForModuleExports = true,
          quotePreference = "double",
          includeAutomaticOptionalChainCompletions = true,
          includeCompletionsWithInsertText = true,
          importModuleSpecifierPreference = "non-relative",
        },

        -- Format options matching Biome config
        tsserver_format_options = {
          insertSpaceAfterCommaDelimiter = true,
          insertSpaceAfterSemicolonInForStatements = true,
          insertSpaceBeforeAndAfterBinaryOperators = true,
          insertSpaceAfterKeywordsInControlFlowStatements = true,
          insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
          insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
          insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
          placeOpenBraceOnNewLineForFunctions = false,
          placeOpenBraceOnNewLineForControlBlocks = false,
          -- Use tabs (matches Biome config)
          convertTabsToSpaces = false,
          indentSize = 2,
          tabSize = 2,
        },
      },
    },
  },
}

