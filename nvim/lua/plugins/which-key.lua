local gh = require('pack').gh

vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = {
    mappings = false,
    separator = '- ',
    keys = {
      -- Esc = "✖ ",
      BS = '⮌',
      Space = ' 󱁐 ',
      -- Tab = "⭾ ",
      -- CR = "↵ ", (Enter)
    },
  },

  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}

-- vim: ts=2 sts=2 sw=2 et
