local plugins = {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

if vim.g.have_nerd_font then
  table.insert(plugins, 'https://github.com/nvim-tree/nvim-web-devicons')
end

vim.pack.add(plugins)

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
vim.keymap.set('n', '<leader>be', '<Cmd>Neotree buffers<CR>', { desc = 'NeoTree buffers' })

require('neo-tree').setup {
  default_component_configs = {
    git_status = {
      symbols = {
        -- Change type
        added = '✚',
        deleted = '✖',
        modified = '✳',
        renamed = '',
        -- Status type
        untracked = '',
        ignored = '⊘',
        unstaged = '',
        staged = '',
        conflict = '',
      },
    },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
  buffers = {
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
