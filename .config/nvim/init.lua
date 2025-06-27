-- 重要なグローバル変数を設定
-- リーダーキーをスペースに設定
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- nvim-matchupとの競合を避けるため、組み込みのmatchitを無効化
vim.g.loaded_matchit = 1

-- モジュール化された設定ファイルを読み込む
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- lazy.nvimプラグインマネージャーのセットアップ
local lazypath = vim.fn.stdpath('data').. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- lazy.nvimの最新の安定版
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグインを読み込む
require('lazy').setup('plugins')

-- lazy.nvimのパスを設定
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- lazy.nvimがインストールされていなければ、GitHubからクローンする
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- lazy.nvimの安定版を使う
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 基礎的なオプションを設定するファイルを読み込む
-- require("core.options") -- この行は後でプラグイン設定内に移動する可能性があります

-- lazy.nvimをセットアップする
-- これで "lua/plugins" ディレクトリ内の全 .lua ファイルがプラグインとして読み込まれる
require("lazy").setup("plugins", {
  -- 必要に応じてlazy.nvimのオプションをここに設定
})
