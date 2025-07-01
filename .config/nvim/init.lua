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
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Enable incremental search
vim.opt.wrapscan = true -- Searches wrap around end of file
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if pattern has uppercase letters
vim.opt.smartindent = true -- Enable smart auto-indenting
vim.opt.backspace = 'indent,eol,start' -- Allow backspace over everything in insert mode
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.history = 1000 -- Keep command history
vim.opt.ruler = true -- Show the cursor position
vim.opt.showcmd = true -- Show partial commands
vim.opt.showmatch = true -- Briefly jump to matching bracket
vim.opt.ttimeout = true -- Enable key code timeout
vim.opt.ttimeoutlen = 100 -- Set key code timeout length to 100ms
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
vim.opt.expandtab = true -- Use spaces instead of tabs (recommended for consistency)
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

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Exit insert/visual mode
map('i', 'jk', '<Esc>')
map('i', 'ｊｋ', '<Esc>') -- Full-width characters
map('v', 'jk', '<Esc>')
-- Wrap word with delimiters
map('n', '\\(', 'i(<Esc>ea)<Esc>')
map('n', '\\{', 'i{<Esc>ea}<Esc>')
map('n', '\\[', 'i[<Esc>ea]<Esc>')
map('n', '\\$', 'i$<Esc>ea$<Esc>')
-- Select all
map('n', '<Leader>a', 'ggVG')
-- Line navigation
map('n', '<Leader><Leader>h', '0')
map('n', '<Leader>h', '^')
map('n', '<Leader>l', '$')
-- Yank to end of line
map('n', 'Y', 'y$')
-- Center screen on search
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
-- Clear search highlight
map('n', '<Leader>n', ':nohl<CR>')
-- Wrap-aware movement
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-- =============================================================================
-- Plugins
-- =============================================================================
require('lazy').setup({
  spec = {
    -- Foundational plugin for syntax-aware features
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter.configs').setup({
          ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'javascript', 'typescript', 'html', 'css', 'json', 'yaml', 'markdown', 'markdown_inline' },
          sync_install = false,
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
          matchup = { enable = true },
        })
      end,
    },

    -- Modern replacement for matchit
    {
      'andymass/vim-matchup',
      event = 'VeryLazy',
    },

    -- LSP / Auto-completion Plugins --
    -----------------------------------

    -- LSP installer and manager
    { "williamboman/mason.nvim", config = function() require("mason").setup() end },

    -- Bridge between mason and lspconfig
    { "williamboman/mason-lspconfig.nvim" },

    -- LSP (Language Server Protocol) foundation
    {
      'neovim/nvim-lspconfig',
      dependencies = { 'williamboman/mason-lspconfig.nvim' },
      config = function()
        -- LSPサーバーが起動した時にキーマップなどを設定するためのautocmd
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            local buf_map = function(mode, lhs, rhs)
              map(mode, lhs, rhs, { buffer = ev.buf, silent = true })
            end
            -- LSP関連のキーマップ
            buf_map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
            buf_map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
            buf_map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
            buf_map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
            buf_map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
            buf_map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
          end,
        })

        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        local servers = { "lua_ls", "ts_ls", "html", "cssls" } -- ts_lsをtsserverに変更

        -- mason-lspconfigでサーバーをインストール
        require('mason-lspconfig').setup({
          ensure_installed = servers,
        })

        -- lspconfigで各サーバーを設定
        for _, server_name in ipairs(servers) do
          require('lspconfig')[server_name].setup({
            capabilities = capabilities,
          })
        end
      end,
    },

    -- Completion engine
    {
      'hrsh7th/nvim-cmp',
      dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
      config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
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
    { 'L3MON4D3/LuaSnip', dependencies = { "rafamadriz/friendly-snippets" } },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- === 日本語入力(skkeleton)の設定 ===
    {
      "vim-skk/skkeleton",
      lazy = true, -- 起動完了後に読み込む
      dependencies = { "vim-denops/denops.vim" },
      config = function()
        vim.fn["skkeleton#config"]({
          globalDictionaries = { "~/.config/skk/SKK-JISYO.L" },
          eggLikeNewline = true,
          userJisyo = "~/.config/skk/SKK-JISYO.user",
        })
        vim.fn["skkeleton#enable"]()
      end,
    },
  },

  -- Performance optimizations
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
        "matchit",
      },
    },
  },
})

-- =============================================================================
-- Color Scheme
-- =============================================================================
if not vim.g.vscode then
  vim.cmd('colorscheme darkblue')
end



