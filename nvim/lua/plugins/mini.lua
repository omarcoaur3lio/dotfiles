local gh = require('pack').gh

vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
-- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

local default_git = statusline.section_git
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_git = function(args)
  local git_info = default_git(args)
  local max_len = 35
  if vim.fn.strchars(git_info) > max_len then
    git_info = vim.fn.strcharpart(git_info, 0, max_len) .. '...'
  end
  return git_info
end

local default_fileinfo = statusline.section_fileinfo
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_fileinfo = function(args)
  args.trunc_width = 9999
  return default_fileinfo(args)
end

local default_filename = statusline.section_filename
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_filename = function(args)
  args.trunc_width = 9999
  return default_filename(args)
end

-- Hide the LSP section ('L' icon and server count '+')
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_lsp = function()
  return ''
end

local default_diff = statusline.section_diff
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_diff = function(args)
  args.icon = '󰊢'
  return default_diff(args)
end

local default_diagnostics = statusline.section_diagnostics
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_diagnostics = function(args)
  args.icon = '  '
  -- args.signs = { ERROR = ' ', WARN = ' ', INFO = ' ', HINT = '💡 ' }
  return default_diagnostics(args)
end

-- vim: ts=2 sts=2 sw=2 et
