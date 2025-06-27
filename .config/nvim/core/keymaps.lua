local keymap = vim.keymap.set

-- ノーマルモード
keymap('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save file', silent = true })
keymap('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit', silent = true })

-- ウィンドウナビゲーション
keymap('n', '<C-h>', '<C-w>h', { desc = 'Move to left window', silent = true })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Move to right window', silent = true })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window', silent = true })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window', silent = true })

-- VSCode環境でのみ有効なキーマップ
if vim.g.vscode then
	-- VSCodeのファイルエクスプローラを開く
	keymap('n', '<leader>e', function() require('vscode').action('workbench.view.explorer') end, { desc = 'VSCode: Toggle Explorer' })
	-- VSCodeの定義へ移動
	keymap('n', 'gd', function() require('vscode').action('editor.action.revealDefinition') end, { desc = 'VSCode: Go to Definition' })
else
	-- スタンドアロンNeovim用のキーマップ
	-- (例：nvim-treeをトグルする)
	keymap('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
	-- LSPの定義へ移動
	keymap('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP: Go to Definition' })

	-- jkでインサートモードを抜ける
	keymap('i', 'jk', '<Esc>', { desc = 'Escape insert mode' })
end
