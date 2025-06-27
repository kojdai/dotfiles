return {
  -- tokyonight.nvim プラグインを指定
  "folke/tokyonight.nvim",
  lazy = false, -- Neovim起動時にすぐに読み込む
  priority = 1000, -- 他のプラグインより先に読み込むように優先度を高く設定
  config = function()
    -- プラグインが読み込まれた後にカラースキームを設定
    vim.cmd.colorscheme "tokyonight"

    -- VSCodeで使う場合は、Neovim側のカラースキームは不要なので、
    -- VSCode環境でない場合のみ適用する、という分岐も有効です。
    -- if not vim.g.vscode then
    --   vim.cmd.colorscheme "tokyonight"
    -- end
  end,
}
