
return {
	-- 両方の環境で必須のプラグイン
	'tpope/vim-surround',
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
	},
	{
		'nvim-matchup/nvim-matchup',
		config = function()
			-- nvim-matchupを有効化
			vim.g.matchup_matchparen_offscreen = { method = 'popup' }
		end,
	},

	-- スタンドアロンNeovimでのみ読み込むプラグイン
	{
		'nvim-lualine/lualine.nvim',
		cond = not vim.g.vscode,
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function() require('lualine').setup() end,
	},
	{
		'nvim-tree/nvim-tree.lua',
		cond = not vim.g.vscode,
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function() require('nvim-tree').setup() end,
	},
	{ 'folke/tokyonight.nvim', cond = not vim.g.vscode },
}
