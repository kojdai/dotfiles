-- Lua 形式スニペット（~/.config/nvim/luasnippets/tex.lua）
-- ファイル名 = filetype。`return { 通常スニペット }, { 自動展開スニペット }` を返す。
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep

return {
	-- "env" → \begin{X} ... \end{X}
	-- ${1} に入れた環境名が \end 側にも自動で反映される（rep で 1 番をミラー）。
	-- JSON では書けない「同じ入力の複数箇所反映」が Lua の強み。
	s("env", {
		t("\\begin{"), i(1, "name"), t("}"),
		t({ "", "\t" }), i(0),
		t({ "", "\\end{" }), rep(1), t("}"),
	}),
}
