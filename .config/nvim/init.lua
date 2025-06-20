
-- ================================================
-- Backup and Undo Settings
-- ================================================
if vim.fn.has('vms') == 1 then
  vim.opt.backup = false
else
  vim.opt.backup = true
  if vim.fn.has('persistent_undo') == 1 then
    vim.opt.undofile = true
  end
end

-- ================================================
-- Search Settings
-- ================================================
vim.opt.hlsearch = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.ttyfast = true

-- ================================================
-- Editing Behavior
-- ================================================
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.clipboard = "unnamedplus"
vim.opt.history = 200
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 100
vim.opt.nrformats:remove("octal")
vim.opt.autoindent = true
vim.opt.showmatch = true
vim.opt.smartindent = true
vim.opt.textwidth = 80

-- ================================================
-- Syntax and Filetype
-- ================================================
vim.cmd("syntax enable")
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.cmd("highlight Comment ctermfg=2 guifg=#008800")
  end,
})
vim.cmd("colorscheme darkblue")
vim.cmd("filetype plugin indent on")
vim.opt.encoding = "utf-8"
vim.opt.fileformats = { "unix", "dos", "mac" }

-- ================================================
-- Plugin and Package Management
-- ================================================
if vim.fn.has('syntax') == 1 and vim.fn.has('eval') == 1 then
  vim.cmd("packadd! matchit")
end

-- ================================================
-- Key Mappings
-- ================================================
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Insert mode: 'jk' or 'ｊｋ' to <Esc>
map('i', 'jk', '<Esc>', {})
map('i', 'ｊｋ', '<Esc>', {})

-- Visual mode: 'jk' to <Esc>
map('v', 'jk', '<Esc>', {})

-- Normal mode: wrap word with (), {}, [], $$
map('n', [[\(]], 'i(<Esc>ea)<Esc>', {})
map('n', [[\{]], 'i{<Esc>ea}<Esc>', {})
map('n', [[\[']], 'i[<Esc>ea]<Esc>', {})
map('n', [[\$]], 'i$<Esc>ea$<Esc>', {})

-- Leader key
vim.g.mapleader = ' '

-- Select all
map('n', '<Leader>a', 'ggVG', opts)

-- Move to beginning/end of line
map('n', '<Leader><Leader>h', '0', opts)
map('n', '<Leader>h', '^', opts)
map('n', '<Leader>l', '$', opts)

-- Y behaves like D and C
map('n', 'Y', 'y$', { noremap = true })

-- ================================================
-- Display and Interface
-- ================================================
vim.opt.sidescroll = 10
vim.opt.whichwrap = 'b,s,<,>,[,],h,l'
vim.opt.list = true
vim.opt.listchars = { tab = '>-', trail = '-' }
vim.opt.cursorline = true
vim.cmd('highlight CursorLine cterm=NONE ctermfg=white ctermbg=DarkGray')
vim.opt.iskeyword = { '@', '48-57', '_', '192-255', '-' }
vim.opt.helplang = { 'ja', 'en' }

-- ================================================
-- Tabs and Indentation
-- ================================================
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- ================================================
-- Navigation Improvements
-- ================================================
map('n', 'j', 'gj', { noremap = true })
map('n', 'k', 'gk', { noremap = true })

-- ================================================
-- File Handling and Performance
-- ================================================
vim.opt.swapfile = false
vim.opt.autoread = true

-- ================================================
-- Miscellaneous
-- ================================================
vim.opt.belloff = 'all'
vim.opt.title = true

