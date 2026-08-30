local gh = require('pack').gh

-- [[ Colorscheme ]]

-- Local Roteki Theme (Development Mode)
-- vim.opt.rtp:prepend('/Users/marco/workplace/roteki-theme-nvim')
vim.pack.add { gh 'omarcoaur3lio/roteki-theme.nvim' }

-- Shortcut to reload the theme during development
vim.keymap.set('n', '<leader>rr', function()
  for name, _ in pairs(package.loaded) do
    if name:match('^roteki') then
      package.loaded[name] = nil
    end
  end
  vim.cmd.colorscheme 'roteki'
  vim.notify('Tema Roteki recarregado!', vim.log.levels.INFO)
end, { desc = '[R]eload [R]oteki Theme' })

-- Koda Theme
-- vim.pack.add { gh 'oskarnurm/koda.nvim' }

-- Load the colorscheme here.
vim.cmd.colorscheme 'roteki'
--vim.cmd.colorscheme 'koda'

-- vim: ts=2 sts=2 sw=2 et
