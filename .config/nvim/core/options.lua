local opt = vim.opt

-- 基本設定
opt.compatible = false
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.termguicolors = true
opt.encoding = 'utf-8'

-- 検索設定
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true
opt.incsearch = true
opt.hlsearch = true

-- UIと挙動
opt.whichwrap = 'b,s,<,>,[,]'
opt.list = true
opt.listchars = 'tab:▸ ,trail:·,nbsp:◇,extends:»,precedes:«'
opt.splitright = true
opt.splitbelow = true
opt.wildmenu = true
opt.scrolloff = 8
opt.laststatus = 2
opt.cursorline = true

