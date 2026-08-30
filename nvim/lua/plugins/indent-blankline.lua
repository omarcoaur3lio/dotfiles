local gh = require('pack').gh

-- [[ Visual indentation guides ]]
vim.pack.add { gh 'lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {}

-- vim: ts=2 sts=2 sw=2 et
