-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Options
-- =============================================================================
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show line relativenumbers
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Enable incremental search
vim.opt.wrapscan = true -- Searches wrap around end of file
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if pattern has uppercase letters
vim.opt.smartindent = true -- Enable smart auto-indenting
vim.opt.backspace = 'indent,eol,start' -- Allow backspace over everything in insert mode
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.history = 10000 -- Keep command history
vim.opt.ruler = true -- Show the cursor position
vim.opt.cursorline = true 
vim.opt.showcmd = true -- Show partial commands
vim.opt.showmatch = true -- Briefly jump to matching bracket
vim.opt.ttimeout = true -- Enable key code timeout
vim.opt.timeoutlen = 300 -- キーマップのタイムアウトを300msに設定
vim.opt.ttimeoutlen = 10 -- こちらは短く保つ
vim.opt.nrformats:remove('octal') -- Disable octal number interpretation
vim.opt.textwidth = 80 -- Automatically wrap lines at 80 characters
vim.opt.encoding = 'utf-8' -- Set file encoding to UTF-8
vim.opt.fileformats = 'unix,dos,mac' -- Set line endings
vim.opt.iskeyword:append('-') -- Treat hyphenated words as whole words
vim.opt.helplang = 'ja,en' -- Set help language to Japanese, then English
vim.opt.whichwrap = 'b,s,<,>,[,],h,l' -- Allow certain keys to move across line boundaries
vim.opt.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 2 -- Number of spaces a <Tab> counts for in editing
vim.opt.expandtab = false -- Use spaces instead of tabs (recommended for consistency)
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false -- Do not keep a backup file
vim.opt.writebackup = false -- Do not create a backup during write
vim.opt.autoread = true -- Automatically reload file if changed outside
vim.opt.wildmenu = true -- Enable command-line completion menu
vim.opt.wildmode = 'longest:full,list:full' -- Command-line completion mode
vim.opt.belloff = 'all' -- Disable all beep sounds
vim.opt.title = true -- Set the terminal window title

vim.opt.list = true
vim.opt.listchars = {
	tab = '>-',
	trail = '·',
	extends = '»',
	precedes = '«',
	nbsp = '␣',
}
-- Set up persistent undo
if vim.fn.has('persistent_undo') == 1 then
	local undodir = vim.fn.stdpath('data') .. '/undodir'
	if vim.fn.isdirectory(undodir) == 0 then
		vim.fn.mkdir(undodir, 'p')
	end
	vim.opt.undofile = true
	vim.opt.undodir = undodir
end

-- =============================================================================
-- Keymaps
-- =============================================================================
vim.g.mapleader = ' ' -- Set leader key to Space

-- Exit insert/visual mode
vim.keymap.set({'i', 'v'}, 'jk', '<Esc>', { noremap = true, silent = true })
vim.keymap.set({'i', 'v'}, 'ｊｋ', '<Esc>', { noremap = true, silent = true })

-- Wrap word with delimiters
vim.keymap.set('n', '\\(', 'i(<Esc>ea)<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '\\{', 'i{<Esc>ea}<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '\\[', 'i[<Esc>ea]<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '\\$', 'i$<Esc>ea$<Esc>', { noremap = true, silent = true })
-- Select all
vim.keymap.set('n', '<Leader>a', 'ggVG', { noremap = true, silent = true })
-- Line navigation
vim.keymap.set('n', '<Leader><Leader>h', '0', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>h', '^', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>l', '$', { noremap = true, silent = true })
-- Yank to end of line
vim.keymap.set('n', 'Y', 'y$', { noremap = true, silent = true })
-- Center screen on search
vim.keymap.set('n', 'n', 'nzz', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzz', { noremap = true, silent = true })
-- Clear search highlight
vim.keymap.set('n', '<Leader>n', ':nohl<CR>', { noremap = true, silent = true })
-- Wrap-aware movement
vim.keymap.set('n', 'j', 'gjzz', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gkzz', { noremap = true, silent = true })
vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-toggle)', { noremap = true, silent = true })

-- =============================================================================
-- Plugins
-- =============================================================================
require('lazy').setup({
	spec = {
		-- カラースキーム
		{
			"rafi/awesome-vim-colorschemes",
			lazy = false,
			priority = 1000,
			config = function()
				vim.cmd.colorscheme "darkblue"
			end,
		},

		-- treesitter
		{
			'nvim-treesitter/nvim-treesitter',
			build = ':TSUpdate',
			event = { "BufReadPost", "BufNewFile" },
			config = function()
				require('nvim-treesitter.configs').setup({
					ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'javascript', 'typescript', 'html', 'css', 'json', 'yaml', 'markdown', 'markdown_inline' },
					sync_install = false,
					auto_install = true,
					highlight = { enable = true },
					indent = { enable = true },
				})
			end,
		},

		-- matchup
		{
			'andymass/vim-matchup',
			event = 'VeryLazy',
		},

		-- LSP / Auto-completion Plugins --
		{
			"williamboman/mason.nvim",
			ft = { "lua", "javascript", "typescript", "html", "css", "yaml", "json", "latex" },
			config = function()
				require("mason").setup()
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "williamboman/mason.nvim" },
			ft = { "lua", "javascript", "typescript", "html", "css", "yaml", "json", "latex" },
		},

		{
			'neovim/nvim-lspconfig',
			dependencies = { 'mason-lspconfig.nvim' },
			ft = { "lua", "javascript", "typescript", "html", "css", "yaml", "json" },
			config = function()
				vim.diagnostic.config({
					virtual_text = true,
					update_in_insert = false,
				})

				local on_attach = function(client, bufnr)
					local buf_map = function(mode, lhs, rhs)
						vim.keymap.set(mode, lhs, rhs, { noremap=true, silent=true, buffer=bufnr })
					end
					-- LSP関連のキーマップ
					buf_map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
					buf_map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
					buf_map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
					buf_map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
					buf_map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
					buf_map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
				end

				local capabilities = require('cmp_nvim_lsp').default_capabilities()
				local servers = { "lua_ls", "ts_ls", "html", "cssls" }

				require('mason-lspconfig').setup({
					-- ensure_installed = servers, -- 自動インストールを無効化
				})

				for _, server_name in ipairs(servers) do
					require('lspconfig')[server_name].setup({
						on_attach = on_attach,
						capabilities = capabilities,
					})
				end
			end,
		},

		-- Completion engine
		{
			'hrsh7th/nvim-cmp',
			event = "InsertEnter",
			dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
			config = function()
				local cmp = require('cmp')
				local luasnip = require('luasnip') -- luasnipをローカル変数として定義
				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						['<C-b>'] = cmp.mapping.scroll_docs(-4),
						['<C-f>'] = cmp.mapping.scroll_docs(4),
						['<C-Space>'] = cmp.mapping.complete(),
						['<C-e>'] = cmp.mapping.abort(),
						['<CR>'] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = 'nvim_lsp' },
						{ name = 'luasnip' },
					}, {
							{ name = 'buffer' },
						}),
				})
			end,
		},
		{ 'hrsh7th/cmp-nvim-lsp', event = "InsertEnter" },
		{ 'L3MON4D3/LuaSnip', event = "InsertEnter", dependencies = { "rafamadriz/friendly-snippets" } },
		{ 'saadparwaiz1/cmp_luasnip', event = "InsertEnter" },

		-- Japanese input
		{
			"vim-skk/skkeleton",
			dependencies = { "vim-denops/denops.vim" },
			ft = { "markdown", "text", "gitcommit", "tex" },
			config = function()
				vim.fn["skkeleton#config"]({
					globalDictionaries = { "~/.config/skk/SKK-JISYO.L" },
					eggLikeNewline = true,
					userDictionary = "~/.config/skk/SKK-JISYO.user",
				})
			end,
		},
	},

	performance = {
		rtp = {
			disabled_plugins = {
				"gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin", "matchit",
			},
		},
	},
})
