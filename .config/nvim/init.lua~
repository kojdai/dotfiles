--==================================================
-- Backup and Undo Settings
--==================================================
if vim.fn.has("vms") == 1 then
	vim.opt.backup = false
else
	vim.opt.backup = true
	if vim.fn.has("persistent_undo") == 1 then
		vim.opt.undofile = true
	end
end

vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true

--==================================================
-- Search Settings
--==================================================

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

--==================================================
-- Editing Behavior
--==================================================
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
vim.opt.scrolloff = 10

--==================================================
-- Syntax and Filetype
--==================================================
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

--==================================================
-- Plugin and Package Management
--==================================================
if vim.fn.has("syntax") == 1 and vim.fn.has("eval") == 1 then
	vim.cmd("packadd! matchit")
end

--==================================================
-- Key Mappings
--==================================================
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local iopts = { noremap = true }

-- 'jk'でインサートモード終了
map("i", "jk", "<Esc>", iopts)
map("i", "ｊｋ", "<Esc>", iopts)
-- 'jk'でビジュアルモード終了
map("v", "jk", "<Esc>", iopts)

-- 単語を()で囲む
map("n", [[\(]], [[i(<Esc>ea)<Esc>]], opts)
map("n", [[\{]], [[i{<Esc>ea}<Esc>]], opts)
map("n", [[\[]], [[i[<Esc>ea]<Esc>]], opts)
map("n", [[\$]], [[i$<Esc>ea$<Esc>]], opts)

-- LeaderキーをSpaceに
vim.g.mapleader = " "

-- 全選択
map("n", "<Leader>a", "ggVG", opts)
-- 行頭へ
map("n", "<Leader><Leader>h", "0", opts)
map("n", "<Leader>h", "^", opts)
-- 行末へ
map("n", "<Leader>l", "$", opts)
-- "Y"を"y$"に
map("n", "Y", "y$", { noremap = true })

--==================================================
-- Display and Interface
--==================================================
vim.opt.sidescroll = 10
vim.opt.whichwrap = "b", "s", "<", ">", "[", "]", "h", "l" 
vim.opt.listchars = { tab = ">-", trail = "-", space = "·" }
vim.opt.list = true
vim.opt.cursorline = true
vim.cmd("highlight CursorLine cterm=NONE ctermfg=white ctermbg=DarkGray")
vim.opt.iskeyword = "@,48-57,_,192-255,-"
vim.opt.helplang = { "ja", "en" }

--==================================================
-- Tabs and Indentation
--==================================================
vim.opt.expandtab = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- ファイルを開いた時に自動でretab!する
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	command = "retab!"
})

--==================================================
-- Navigation Improvements
--==================================================
map("n", "j", "gj", { noremap = true })
map("n", "k", "gk", { noremap = true })

--==================================================
-- File Handling and Performance
--==================================================
vim.opt.swapfile = false
vim.opt.autoread = true

--==================================================
-- Miscellaneous
--==================================================
vim.opt.belloff = "all"
vim.opt.title = true
