local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("markdown", {
  s("front", {
    t({ "---" }),
    t({ "", 'title: "' }),
    i(1, "Title"),
    t({ '"' }),
    t({ "", 'description: "' }),
    i(2, "Description"),
    t({ '"' }),
    t({ "", "publishDate: " }),
    i(3, "2025-07-28"),
    t({ "", 'tags: ["' }),
    i(4, "tag1"),
    t({ '"]' }),
    t({ "", "---", "" }),
    i(0),
  }),
})
