-- =============================================================================
-- Neovim 設定（本格移行版）
--   方針:
--     ① ~/.vimrc の設定を「source せず」ネイティブ Lua に翻訳して再現する
--        （vimrc は dotfiles に温存。今後 nvim は init.lua で独立管理）
--     ② lazy.nvim でプラグイン管理（段階的に追加していく）
--     ③ WSL2 クリップボード / markdown 閲覧 / zk LSP は従来どおり上乗せ
-- =============================================================================

-- =============================================================================
-- 起動高速化（最優先で実行）
--   ・vim.loader: lua モジュールのバイトコードキャッシュ（2回目以降の起動を短縮）
--   ・未使用言語プロバイダを無効化（python3/ruby/perl/node の起動時チェックを省略）
--     ※ 将来 markdown-preview 等 node 依存を入れる場合は node を 1 に戻す。
-- =============================================================================
if vim.loader then vim.loader.enable() end
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- 未使用の組み込みランタイムプラグインを無効化（起動時の sourcing を省略）。
--   netrw は oil で置換済み。アーカイブ編集・tutor 等も普段使わない。
--   ※ spellfile/matchparen/matchit は残す（綴り確認・括弧対応で使うため）。
for _, p in ipairs({
	"netrwPlugin", "netrw",          -- ファイラは oil
	"tarPlugin", "zipPlugin", "gzip", -- 圧縮ファイルを nvim で直接編集しない
	"tohtml", "tutor",                -- :TOhtml / :Tutor 未使用
	"rplugin",                        -- remote plugin（プロバイダ無効化済み）
}) do
	vim.g["loaded_" .. p] = 1
end

-- =============================================================================
-- 0) リーダーキー（keymap / プラグイン読込より前に設定する必要がある）
--    let mapleader = "\<Space>"
-- =============================================================================
vim.g.mapleader = " "
-- localleader は \（バックスラッシュ）。VimTeX のマップ(<localleader>ll 等)を \ll/\lv に。
-- ※ Space にすると <Space>l→$ と衝突して VimTeX のコンパイルキーが発火しない。
vim.g.maplocalleader = "\\"

-- =============================================================================
-- 1) オプション（~/.vimrc の `set ...` を翻訳）
--    nvim の既定値で十分なもの（incsearch/wrapscan/wildmenu/backspace/ruler/
--    showcmd/ttimeout/syntax/filetype 等）は省略し、vim と差が出る項目のみ明示。
-- =============================================================================
local opt = vim.opt

-- バックアップ・Undo
opt.backup = false       -- set nobackup
opt.writebackup = false  -- set nowritebackup
opt.swapfile = false     -- set noswapfile
opt.undofile = true      -- set undofile（永続Undo）
-- undodir は nvim 専用にする。vim と ~/.vim/undodir を共有すると undo ファイル形式が
-- 非互換で「E824: Incompatible undo file」になるため分離する（無ければ自動作成）。
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir

-- 検索
opt.hlsearch = true      -- 最後の検索をハイライト
opt.ignorecase = true    -- 検索時に大文字小文字を無視
opt.smartcase = true     -- ただし大文字を含むときは区別

-- 行番号
opt.number = true         -- 絶対行番号
opt.relativenumber = true -- 相対行番号（移動しやすく）

-- 編集挙動
opt.clipboard = "unnamedplus" -- y/d/c/p で + レジスタ（システムクリップボード）
opt.history = 1000            -- コマンド/検索履歴
opt.ttimeoutlen = 50          -- キーコードのタイムアウト（Esc 応答を速く）
opt.nrformats:remove("octal") -- 0 始まりを8進数として扱わない
opt.showmatch = true          -- 対応する括弧へ一瞬ジャンプ
opt.scrolloff = 10            -- カーソル上下に最低10行残す
opt.sidescroll = 10          -- 横スクロール量

-- 表示・インターフェース
opt.whichwrap = "b,s,<,>,[,],h,l"               -- 行端をまたいで移動可
opt.listchars = { tab = ">-", trail = "-", space = "·" } -- 不可視文字の見た目
opt.list = true                                  -- 不可視文字を表示
opt.iskeyword = "@,48-57,_,192-255,-"            -- 単語の構成文字（- を含む）
opt.helplang = { "ja", "en" }                    -- ヘルプ言語
opt.spelllang = { "en", "cjk" }                  -- 綴り確認は英語のみ。cjk で日本語に波線を付けない

-- タブ・インデント（既定はタブ文字・幅2。Python だけ後述の autocmd で 4スペース）
opt.expandtab = false -- set noexpandtab
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- ファイル取り扱い・補完
opt.autoread = true                              -- 外部変更を自動再読込
opt.fileformats = { "unix", "dos", "mac" }
opt.wildmode = { "longest:full", "list:full" }   -- コマンドライン補完
-- 挿入補完（LSP の \cite{ / \begin{ ポップアップなど）のフィルタ挙動。
--   ・menuone : 候補が1件でもポップアップを出す
--   ・noselect: 自動で先頭候補を確定挿入しない（打鍵で絞ってから選ぶ）
--   ・fuzzy   : 打った文字でファジー一致フィルタ（前方一致だけでなく部分一致でも絞り込む）。
--     これが無いと texlab の \begin{align} 等（word が "\" 始まり）や bib キーが頭から
--     一致せず「候補が出るのに絞り込まれない」状態になる（nvim 0.11+ の機能）。
opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }

-- その他
opt.belloff = "all" -- ビープ全停止
opt.title = true    -- 端末タイトルにファイル名

-- '%' でのタグ/構文対応移動を強化（HTML タグや if/else 等）
vim.cmd("silent! packadd! matchit")

-- =============================================================================
-- 2) キーマップ（~/.vimrc の各 *map を翻訳）
-- =============================================================================
local map = vim.keymap.set

-- jk で Esc（挿入・ビジュアル）
map("i", "jk", "<Esc>")
map("v", "jk", "<Esc>")

-- 単語を括弧で囲む（normal）
map("n", "\\(", "i(<Esc>ea)<Esc>", { desc = "wrap word with ()" })
map("n", "\\{", "i{<Esc>ea}<Esc>", { desc = "wrap word with {}" })
map("n", "\\[", "i[<Esc>ea]<Esc>", { desc = "wrap word with []" })
map("n", "\\$", "i$<Esc>ea$<Esc>", { desc = "wrap word with $$" })

-- VSCode風: Ctrl+/ で行コメントをトグル（コメント記号は filetype 依存で自動判定：
--   .tex は %、lua は -- 等）。nvim 標準の gcc(行)/gc(選択範囲) を使うため remap=true。
--   端末では Ctrl+/ が <C-_>(0x1f) として送られることが多いので両方マップする。
--   ・normal : 現在行をトグル（行内のどこにカーソルがあってもOK）
--   ・visual : 選択した複数行をトグル
--   ・insert : <C-o> で一旦ノーマルに出て gcc、すぐ挿入へ戻る
for _, key in ipairs({ "<C-_>", "<C-/>" }) do
	map("n", key, "gcc", { remap = true, desc = "toggle comment line" })
	map("x", key, "gc", { remap = true, desc = "toggle comment (selection)" })
	map("i", key, "<C-o>gcc", { remap = true, desc = "toggle comment line" })
end

-- 移動・選択（Space リーダー）
map("n", "<Leader>a", "ggVG", { desc = "select all" })
map("n", "<Leader><Leader>h", "0", { desc = "line start (col 0)" })
map("n", "<Leader>h", "^", { desc = "first non-blank" })
map("n", "<Leader>l", "$", { desc = "line end" })
map("n", "<Leader>k", "gg", { desc = "top of file" })
map("n", "<Leader>j", "G", { desc = "end of file" })
map("n", "<Leader>n", ":nohl<CR>", { desc = "clear search highlight" })

-- Y を D/C と揃える（行末までヤンク）
map("n", "Y", "y$")

-- 検索後に中央表示
map("n", "n", "nzz")
map("n", "N", "Nzz")

-- 表示行で移動しつつ中央寄せ
map("n", "j", "gjzz")
map("n", "k", "gkzz")

-- ペースト時に Windows 改行(^M)を自動除去
map("n", "p", "p:keeppatterns '[,']s/\\r//ge<CR>", { silent = true })
map("n", "P", "P:keeppatterns '[,']s/\\r//ge<CR>", { silent = true })

-- =============================================================================
-- 3) autocmd / ハイライト（~/.vimrc 由来）
-- =============================================================================
-- カラースキーム適用時に走らせる好みのハイライト上書き（colorscheme 切替でも維持）。
-- colorscheme より前に登録しておき、:colorscheme 実行時に毎回発火させる。
local function apply_custom_highlights()
	-- ① 背景透過: WezTerm の window_background_opacity(0.95) を活かすため、
	--    エディタ本体の背景を NONE にして端末の背景を透けさせる。
	--    ※ ポップアップ(NormalFloat)は読みやすさ優先であえて透過させない。
	for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer", "NonText", "FoldColumn" }) do
		vim.api.nvim_set_hl(0, g, { bg = "NONE" })
	end
	-- ② ~/.vimrc 由来: コメントを緑に
	vim.cmd("highlight Comment ctermfg=2 guifg=#008800")
	-- ③ ~/.vimrc 由来: カーソル行（guifg=NONE で現在行の構文色を潰さないよう微調整）
	vim.cmd("highlight CursorLine gui=bold guifg=NONE guibg=#3c3c3c cterm=bold ctermfg=white ctermbg=DarkGray")
end

vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = apply_custom_highlights })

-- 挿入中はカーソル行ハイライトを消し、抜けたら戻す
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function() vim.opt.cursorline = false end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function() vim.opt.cursorline = true end,
})

-- Python は PEP8（4スペース）
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- LaTeX では conceal を無効化する。
-- conceallevel=2 はもともと markdown(zk) の [[a|b]] 表示用。tex に効くと VimTeX が
-- \textbf{} や \quad を隠してソースが見えなくなり紛らわしいので、tex だけ 0 に戻す。
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex", "latex", "plaintex", "bib" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Markdown: 見出しアウトラインを fzf-lua で一覧→選んでジャンプ。
--   treesitter 不要（純パターンで `# 見出し` を収集）。コードブロック内の # は除外。
--   zk の長いノートを回遊する用途。<leader>mo で起動。
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		vim.keymap.set("n", "<Leader>mo", function()
			local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
			local items, by_label = {}, {}
			local in_code = false
			for i, line in ipairs(lines) do
				if line:match("^```") or line:match("^~~~") then
					in_code = not in_code
				elseif not in_code then
					local hashes, text = line:match("^(#+)%s+(.+)$")
					if hashes then
						local label = i .. "\t" .. string.rep("  ", #hashes - 1) .. text
						items[#items + 1] = label
						by_label[label] = i
					end
				end
			end
			if #items == 0 then
				vim.notify("見出しが見つかりません", vim.log.levels.INFO)
				return
			end
			require("fzf-lua").fzf_exec(items, {
				prompt = "Outline> ",
				fzf_opts = { ["--delimiter"] = "\t", ["--with-nth"] = "2" }, -- 行番号(1列目)は隠す
				actions = {
					["default"] = function(selected)
						local lnum = selected and selected[1] and by_label[selected[1]]
						if lnum then
							vim.api.nvim_win_set_cursor(0, { lnum, 0 })
							vim.cmd("normal! zz")
						end
					end,
				},
			})
		end, { buffer = args.buf, desc = "Markdown: 見出しアウトライン" })
	end,
})

-- カーソル位置に日時を挿入（外部プロセス不要）。Zettelkasten のタイムスタンプ用。
vim.api.nvim_create_user_command("InsertDatetime", function()
	local stamp = vim.fn.strftime("%Y-%m-%d %H:%M:%S")
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { stamp })
end, { desc = "カーソル位置に日時(YYYY-MM-DD HH:MM:SS)を挿入" })

-- :now と打つだけで InsertDatetime を実行（ユーザーコマンドは大文字始まり必須なので略語で代用）。
-- コマンドラインの先頭が "now" のときだけ展開し、引数中の now は誤展開しない。
vim.cmd([[cnoreabbrev <expr> now (getcmdtype() == ':' && getcmdline() ==# 'now') ? 'InsertDatetime' : 'now']])

-- truecolor（モダンな colorscheme と背景透過に必要）
vim.opt.termguicolors = true
-- ※ 既定カラースキームは lazy の tokyonight プラグインが適用する（その際 ColorScheme
--   autocmd が発火して透過と好み設定が当たる）。ここで desert を読むのは二重ロードで
--   無駄なため廃止した（起動高速化）。

-- =============================================================================
-- 4) lazy.nvim ブートストラップ + プラグイン
--    まだ最小構成。oil.nvim（ファイラ）から段階的に増やす。
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- oil.nvim : バッファとしてディレクトリを編集できるファイラ（netrw 置換）
	--   `-` で親ディレクトリを開く（oil の作法）。まずは既定設定。
	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン（任意）
		config = function(_, opts)
			require("oil").setup(opts)
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir (oil)" })
		end,
	},

	-- カラースキーム（複数入れて :colorscheme <名前> で見比べ・切替できる）
	--   priority=1000 / lazy=false で他プラグインより先に確実に読み込む。
	{
		-- :colorscheme kanagawa で切替可能（既定にはしない）。
		-- 既定は tokyonight なので起動時には読まない。lazy.nvim は :colorscheme 実行時に
		-- 自動ロードするため lazy=true でよい（先読みの無駄 require を削減）。
		"rebelot/kanagawa.nvim",
		lazy = true,
		opts = { transparent = true }, -- プラグイン側でも背景透過
	},
	{
		-- 既定スキーム：tokyonight（storm）
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm",     -- night / storm / moon / day から storm
				transparent = true,  -- 背景透過（autocmd の透過と二重で安全）
			})
			vim.cmd.colorscheme("tokyonight") -- 既定として適用
		end,
	},

	-- flash.nvim : easymotion 相当のジャンプ（段階2・最小構成）
	--   <leader>s + 数文字 → 画面内の候補にラベルが付き、ラベルキーで一気に移動。
	--   ※ s はバニラの「文字置換(substitute)」を残すため flash には割り当てない。
	--   f/t/F/T もバニラのまま（char.enabled=false）。後で必要なら true に。
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = { char = { enabled = false } }, -- f/t/F/T を変更しない
		},
		keys = {
			{ "<leader>s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
		},
	},

	-- fzf-lua : Lua製ファジーファインダー（fzf + ripgrep）。最小構成。
	--   <leader>f 名前空間（既存の <leader> マッピングと衝突なし）。
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "FzfLua",
		keys = {
			{ "<leader>ff", function() require("fzf-lua").files() end, desc = "fzf: files" },
			{ "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "fzf: live grep" },
			{ "<leader>fb", function() require("fzf-lua").buffers() end, desc = "fzf: buffers" },
			{ "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "fzf: recent files" },
			{ "<leader>fh", function() require("fzf-lua").helptags() end, desc = "fzf: help tags" },
		},
		opts = {},
	},

	-- local-highlight.nvim : カーソル下の単語と同じ語を画面内で強調（最小構成）。
	--   派手にならないよう控えめな下線にする。
	{
		"tzachar/local-highlight.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("local-highlight").setup({
				hlgroup = "LocalHighlight",      -- 下で定義する下線スタイル
				animate = { enabled = false },   -- アニメは snacks.nvim 依存なので無効化
			})
			-- 下線のみ（色はテキスト色に追従）。colorscheme 切替でも残る独自グループ。
			vim.api.nvim_set_hl(0, "LocalHighlight", { underline = true })
		end,
	},

	-- === 知的生産向け強化バッチ（ペルソナ起点） ====================================

	-- ※ nvim-treesitter は当面入れない。
	--   理由: この環境に C コンパイラ(cc/gcc)が無くパーサをビルドできず、かつ nvim が
	--   markdown/markdown_inline パーサをバンドル済みなので render-markdown は単体で動く。
	--   多言語の高度なハイライトが欲しくなったら `sudo apt install build-essential` 後に追加する。

	-- ① mini.surround : 囲み操作（自作 \( 等の正攻法版）。
	--    flash が s を使うため gs プレフィックスに退避（gsa 追加 / gsd 削除 / gsr 置換）。
	{
		"echasnovski/mini.surround",
		version = false,
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "gsa",            -- 例: gsaiw) で単語を () で囲む
				delete = "gsd",         -- 例: gsd) で () を外す
				replace = "gsr",        -- 例: gsr)] で ) を ] に置換
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				update_n_lines = "gsn",
			},
		},
	},

	-- ② render-markdown : markdown をバッファ内で整形表示（zk ノート閲覧/執筆）。
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- パーサは nvim バンドルを使用
		ft = { "markdown" }, -- markdown を開いたときだけ読み込む（.tex では起動すらしない）
		opts = {
			file_types = { "markdown" }, -- 描画対象を markdown に限定（latex/tex では一切描画しない）
			sign = { enabled = false },  -- サイン列のアイコンを出さない（モード切替で左幅が揺れるのを防ぐ）
		},
	},

	-- ③ which-key : <Space> 後に押せるキー一覧をポップアップ（記憶に頼らない）。
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- ④ img-clip : クリップボードの画像を貼付け→保存＋markdownリンク挿入。
	--    ※ WSL2 では powershell.exe 経由で取得（別途 PowerShell が使える前提）。
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			default = {
				dir_path = "assets",            -- ノートと同階層の assets/ に保存
				relative_to_current_file = true,
			},
			filetypes = {
				markdown = { url_encode_path = true, template = "![$CURSOR]($FILE_PATH)" },
			},
		},
		keys = {
			{ "<leader>p", function() require("img-clip").paste_image() end, desc = "img: paste image" },
		},
	},

	-- ⑤a auto-save : 低摩擦capture。InsertLeave / TextChanged で自動保存。
	{
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" },
		opts = {},
	},

	-- ⑤b persistence : ディレクトリ単位でセッション保存・復元（前回の続きから）。
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
		keys = {
			{ "<leader>qs", function() require("persistence").load() end, desc = "session: restore (cwd)" },
			{ "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "session: restore last" },
			{ "<leader>qd", function() require("persistence").stop() end, desc = "session: don't save" },
		},
	},

	-- ⑥ vimdoc-ja : Vim ヘルプの日本語版（helplang=ja を活かす）。
	{
		"vim-jp/vimdoc-ja",
		event = "VeryLazy", -- 起動後に遅延ロード（:help までに間に合う）
	},

	-- ⑦ vimtex : LaTeX 執筆（卒論・beamer）。コンパイルは latexmk。
	--    ※ vimtex は filetype で自前 lazy 化するため lazy=false 推奨。
	--    ※ WSL2 の PDF ビューア連携（前方/後方検索）は別途設定が必要。
	{
		"lervag/vimtex",
		ft = { "tex", "plaintex", "bib" }, -- .tex を開いた時だけ読み込む（起動高速化）
		init = function()
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_view_method = "zathura" -- WSLg で窓表示。自動リロード＋順/逆方向検索
			-- 既定では VimTeX が -pdf(pdflatex) を強制し、日本語クラス jlreq が壊れる。
			-- lualatex を使わせる（.latexmkrc の $pdf_mode=4 とも整合）。
			vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
			-- PDF/synctex は out/ に出る（.latexmkrc の $out_dir='out'）。vimtex にも教える。
			vim.g.vimtex_compiler_latexmk = { out_dir = "out" }
			-- quickfix（画面下のログ窓）は「エラー時だけ」開く。警告だけのときは開かない。
			--   既定の vimtex_quickfix_mode=2（開くがジャンプしない）は維持しつつ、
			--   警告のみのコンパイルでは窓を出さない（普段は邪魔なため）。
			vim.g.vimtex_quickfix_open_on_warning = 0
		end,
	},

	-- zk-nvim : zk のネイティブ統合（新規ノート/全文検索/タグ/選択範囲→ノート）。
	--   ※ 既存の手動 zk LSP(vim.lsp.enable("zk"))をそのまま使うため auto_attach は無効化。
	--      zk-nvim は名前 "zk" のクライアントを見つけてコマンドを実行する。picker は fzf-lua。
	{
		"zk-org/zk-nvim",
		ft = "markdown",
		cmd = { "ZkNew", "ZkNotes", "ZkTags", "ZkBacklinks", "ZkLinks", "ZkMatch" },
		keys = {
			{ "<leader>zo", "<Cmd>ZkNotes<CR>", desc = "zk: search/open notes" },
			{ "<leader>zt", "<Cmd>ZkTags<CR>", desc = "zk: browse tags" },
			{ "<leader>zn", "<Cmd>ZkNew<CR>", desc = "zk: new note" },
			{ "<leader>zN", ":'<,'>ZkNewFromContentSelection<CR>", mode = "x", desc = "zk: new note from selection" },
		},
		opts = {
			picker = "fzf_lua",
			lsp = { auto_attach = { enabled = false } }, -- LSP は手動設定を流用
		},
		config = function(_, opts)
			require("zk").setup(opts)
		end,
	},

	-- LuaSnip : スニペットエンジン（friendly-snippets 同梱）。
	--   ※ jsregexp(build) は C コンパイラ必須なので省略（無くても大半のスニペットは動く）。
	--   展開/移動: <C-k> 展開・次へ / <C-j> 前へ（insert/select）。
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		event = "InsertEnter",
		config = function()
			local from_vscode = require("luasnip.loaders.from_vscode")
			from_vscode.lazy_load() -- friendly-snippets（runtimepath 上の vscode 形式）
			-- 自作①: VSCode(JSON)形式 ~/.config/nvim/snippets/
			from_vscode.lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
			-- 自作②: Lua 形式 ~/.config/nvim/luasnippets/<filetype>.lua（動的スニペット向け）
			require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/luasnippets" } })
		end,
		keys = {
			-- <C-k>: スニペット展開中なら次のタブストップへジャンプ。
			--        そうでなければ fzf-lua でスニペットをファジー検索→選択して挿入。
			{
				"<C-k>",
				function()
					local ls = require("luasnip")
					if ls.jumpable(1) then
						ls.jump(1)
						return
					end
					-- 現在の filetype + "all" の全スニペットを集めて fzf-lua に渡す
					local by_label, items = {}, {}
					local function collect(list)
						for _, snip in ipairs(list or {}) do
							local trig = snip.trigger or "?"
							local desc = (snip.dscr and table.concat(snip.dscr, " ")) or snip.name or ""
							local label = trig .. "\t" .. desc
							by_label[label] = snip
							items[#items + 1] = label
						end
					end
					collect(ls.get_snippets("all"))
					collect(ls.get_snippets(vim.bo.filetype))
					if #items == 0 then
						vim.notify("利用可能なスニペットがありません", vim.log.levels.INFO)
						return
					end
					require("fzf-lua").fzf_exec(items, {
						prompt = "Snippets> ",
						fzf_opts = { ["--delimiter"] = "\t", ["--with-nth"] = "1,2" },
						actions = {
							["default"] = function(selected)
								local snip = selected and selected[1] and by_label[selected[1]]
								if snip then
									vim.schedule(function() ls.snip_expand(snip) end)
								end
							end,
						},
					})
				end,
				mode = { "i", "s" },
				desc = "snippet: jump fwd / fuzzy insert",
			},
			{ "<C-j>", function() local ls = require("luasnip"); if ls.jumpable(-1) then ls.jump(-1) end end, mode = { "i", "s" }, desc = "snippet: jump back" },
		},
	},

	-- luasnip-latex-snippets : Gilles Castel 流の高速 LaTeX スニペット（自動展開）。
	--   数式判定は VimTeX を使用（use_treesitter=false）。例: 数式中で "ff"→\frac{}{}, "//"→分数 等。
	{
		"iurimateus/luasnip-latex-snippets.nvim",
		dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
		ft = { "tex", "markdown" },
		config = function()
			require("luasnip-latex-snippets").setup({ use_treesitter = false })
			require("luasnip").config.setup({ enable_autosnippets = true })
		end,
	},
}, {
	-- lazy 本体の設定
	checker = { enabled = false },           -- 自動アップデート確認はオフ（好み次第で変更）
	change_detection = { notify = false },   -- 設定変更の通知を抑制
})

-- =============================================================================
-- 5) WSL2 クリップボード（y/p で Windows クリップボード連携）
--   方針: clipboard=unnamedplus なので y/d/x/c の度にコピー処理が走る。win32yank.exe は
--   WSL→Windows 境界越しの起動コストが温まっても ~180ms、初回(Defenderスキャン)は ~1s かかり、
--   キー操作ごとに固まる原因になっていた。
--   そこで「コピー(書込み)はプロセス起動ゼロの OSC 52」で瞬時にし、頻度の低い「ペースト(読込み)
--   だけ win32yank.exe」を使う（双方向の Windows クリップボード同期は維持）。
--   ・コピー: OSC 52（WezTerm が受信して Windows クリップボードへ。UTF-8 安全・即時）
--   ・ペースト: win32yank.exe -o --lf（CRLF→LF で ^M を残さない）
--   ※ OSC 52 は LF 改行のまま送る。Windows 側で CRLF が要る稀なケースのみ要注意。
-- =============================================================================
if vim.fn.executable("win32yank.exe") == 1 then
	local osc52 = require("vim.ui.clipboard.osc52")
	local function win32yank_paste()
		-- win32yank.exe -o は OSC52 で送った生バイト列を返すだけで、行単位/文字単位の
		-- レジスタ種別(regtype)情報を持たない。systemlist だと末尾改行が捨てられ、
		-- yy でコピーした行も charwise 扱いになり「yy p」が行複製にならず行内挿入になる。
		-- そこで末尾が改行なら linewise("V") と判定し、{lines, regtype} 形式で返す。
		local text = vim.fn.system("win32yank.exe -o --lf")
		local regtype = (text:sub(-1) == "\n") and "V" or "v"
		local lines = vim.split(text, "\n")
		if regtype == "V" and lines[#lines] == "" then
			table.remove(lines) -- linewise の末尾空要素を除去
		end
		return { lines, regtype }
	end
	vim.g.clipboard = {
		name = "osc52-copy/win32yank-paste",
		copy = {
			["+"] = osc52.copy("+"),
			["*"] = osc52.copy("*"),
		},
		paste = {
			["+"] = win32yank_paste,
			["*"] = win32yank_paste,
		},
		cache_enabled = 0,
	}
end

-- vim と同じくマウスを掴まない（端末側のドラッグ選択→Ctrl+Shift+C を活かす）
vim.opt.mouse = ""

-- =============================================================================
-- 6) マークダウンを読みやすく（zk ノート閲覧用）
-- =============================================================================
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.conceallevel = 2 -- [[a|b]] のラベル表示などを綺麗に

-- 散文（tex/markdown/text）では list をオフにする。コードでは不可視文字を
-- 見たいので list は残し、散文のときだけ切り替える。
-- ※ linebreak は off にする。linebreak=true は「breakat 文字（半角スペース・
--   - , . ( など）まで遡って折り返す」英文向けの機能で、単語間スペースの無い
--   日本語本文では \cite{...} 内のカンマやハイフン等まで遡って改行され、画面右端
--   まで届かない「変な改行」になる。日本語はどの文字位置でも改行できるので、
--   linebreak=false（画面右端でそのまま折り返す）が正しい。
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex", "plaintex", "markdown", "text" },
	callback = function()
		vim.opt_local.list = false
		vim.opt_local.linebreak = false
	end,
})

-- =============================================================================
-- 7) zk LSP（zk 自身が language server。`zk lsp` で起動）
--   * `[[` で既存ノートをタイトル補完して挿入（Obsidian風）
--   * デッドリンク等の診断、K でホバー、gd で定義（リンク先）ジャンプ
-- =============================================================================
vim.lsp.config("zk", {
	cmd = { "zk", "lsp" },
	filetypes = { "markdown" },
	root_markers = { ".zk" }, -- ノートブックのルート（~/zkNote/.zk）を自動検出
})
vim.lsp.enable("zk")

-- =============================================================================
-- 7.5) texlab LSP（LaTeX 用。VSCode 風に \cite{ や \ref{ で候補ポップアップ）
--   * \cite{ を入力すると bib.bib のエントリ（著者・年・タイトル）を補完
--   * 本文は sec/*.tex に \input 分割しているが、texlab はフォルダ全体を走査し
--     main.tex の \bibliography{bib} を辿るので、サブファイル編集中でも候補が出る
--   * コンパイル/プレビューは引き続き VimTeX(latexmk) が担当。texlab は既定で
--     保存時ビルドしない（build.onSave=false）ため衝突しない
--   * 補完の自動ポップアップ/K/gd は下の LspAttach（全LSP共通）がそのまま適用
-- =============================================================================
vim.lsp.config("texlab", {
	cmd = { "texlab" },
	filetypes = { "tex", "plaintex", "bib" },
	-- main.tex / .latexmkrc / .git のあるフォルダをプロジェクトルートとみなす
	root_markers = { ".latexmkrc", "main.tex", ".git" },
})
vim.lsp.enable("texlab")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			-- `[[` などのトリガで自動補完ポップアップ
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- リンク先へジャンプ
		vim.keymap.set("n", "<leader>zb", vim.lsp.buf.references, opts) -- バックリンク一覧
	end,
})

-- 補完ポップアップ中は Tab/S-Tab で選択、Enter で確定
vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- =============================================================================
-- 8) <leader>zl : fzf でノートをキーワード検索して [[stem|title]] を挿入
--   bat でプレビューしながら選べる Notion/Obsidian 風の導線。
-- =============================================================================
local function zk_insert_link()
	local nb = vim.env.ZK_NOTEBOOK_DIR or (vim.env.HOME .. "/zkNote")
	local tmp = vim.fn.tempname()
	local sh = string.format(
		[[cd %q && zk list --quiet --no-pager --format $'{{title}}\t{{filename-stem}}\t{{abs-path}}' ]]
			.. [[| fzf --delimiter='\t' --with-nth=1 --prompt='link> ' ]]
			.. [[--preview 'bat --color=always --style=plain --line-range :200 {3}' ]]
			.. [[--preview-window=right:60%% > %q]],
		nb,
		tmp
	)

	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.85)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.fn.jobstart({ "bash", "-c", sh }, {
		term = true,
		on_exit = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			local lines = vim.fn.readfile(tmp)
			vim.fn.delete(tmp)
			if #lines == 0 or lines[1] == "" then
				return
			end
			local title, stem = lines[1]:match("^(.-)\t(.-)\t")
			if not stem or stem == "" then
				return
			end
			vim.api.nvim_put({ string.format("[[%s|%s]]", stem, title) }, "c", true, true)
		end,
	})
	vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("ZkLink", zk_insert_link, {})
vim.keymap.set("n", "<leader>zl", zk_insert_link, { desc = "zk: insert link" })
vim.keymap.set("i", "<C-l>", function()
	vim.cmd("stopinsert")
	zk_insert_link()
end, { desc = "zk: insert link" })
