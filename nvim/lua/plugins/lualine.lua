local gh = require('pack').gh

vim.pack.add { gh 'nvim-lualine/lualine.nvim' }

vim.opt.laststatus = 3

require('lualine').setup {
  options = {
    theme = "auto",
    globalstatus = true,
    component_separators = "",
    section_separators = { left = "", right = "" },
    disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter" } },
  },
  sections = {
    lualine_a = {
      { "mode", separator = { left = "┃│", right = "" }, padding = { left = 1, right = 1 } },
    },
    lualine_b = {
      { 
        "branch", 
        icon = "", 
        separator = { right = "" }, 
        padding = { left = 1, right = 1 },
        fmt = function(str)
          local max_len = 35
          if vim.fn.strchars(str) > max_len then
            return vim.fn.strcharpart(str, 0, max_len) .. "..."
          end
          return str
        end
      },
    },
    lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { "filename", path = 1 },
    },
    lualine_x = {
      {
        "diagnostics",
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
      },
      {
        "diff",
        symbols = { added = " ", modified = " ", removed = " " },
      },
    },
    lualine_y = {
      { "progress", separator = { left = "" }, padding = { left = 1, right = 1 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if next(clients) == nil then return " Sem LSP" end
          local names = {}
          for _, client in ipairs(clients) do
            table.insert(names, client.name)
          end
          return "  " .. table.concat(names, ", ")
        end,
        separator = { left = "", right = "│┃" },
        padding = { left = 1, right = 1 },
      },
    },
  },
  extensions = { "nvim-tree", "fzf" },
}

-- vim: ts=2 sts=2 sw=2 et
