-- WezTermのAPIを読み込む
local wezterm = require 'wezterm'

-- 設定オブジェクトを生成する
local config = wezterm.config_builder()

-- ============================================================================
-- 1. 基本設定
-- ============================================================================
-- 起動プログラムを「Ubuntu-24.04」に指定し、ホームディレクトリから開始する
config.default_prog = { 'wsl.exe', '--cd', '~', '-d', 'Ubuntu-24.04' }

config.automatically_reload_config = true
-- スクロールバック行数（既定 3500 だと Claude Code の長いログを遡りきれないため拡張）
config.scrollback_lines = 100000
config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.95
config.macos_window_background_blur = 80

-- ============================================================================
-- 2. タブバー (Tab) の設定
-- ============================================================================
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true

-- タブバーの透過
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
	colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false

-- タブ同士の境界線を非表示
config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},
}

-- ============================================================================
-- 3. タブのカスタムフォーマット (イベント処理)
-- ============================================================================
-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local edge_background = "none"
	
	if tab.is_active then
		background = "#ae8b2d"
		foreground = "#FFFFFF"
	end
	
	local edge_foreground = background
	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
	
	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

-- ============================================================================
-- 4. 画面分割とキーバインド（Vimユーザー向け）
-- ============================================================================
-- 「Leaderキー」を設定（ここでは Ctrl + e をリーダーキーにします）
config.leader = { key = 'e', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
	-- ==================== モード切り替え ====================
	-- コピーモード起動
	-- 操作: Ctrl+e を押して離した後、v を押す
	{ key = 'v', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },

	-- ==================== ペイン分割 ====================
	-- 縦に分割 (Vimの :vsplit のイメージ)
	-- 操作: Ctrl+e を押して離した後、\ (バックスラッシュ) を押す
	{ key = '\\', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	
	-- 横に分割 (Vimの :split のイメージ)
	-- 操作: Ctrl+e を押して離した後、s を押す
	{ key = 's', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
	
	-- ==================== ペイン移動 ====================
	-- 分割した画面（ペイン）間の移動を Vim の hjkl キーで行う
	-- 操作: Ctrl+e を押して離した後、h, j, k, l のいずれかを押す
	{ key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Left') },
	{ key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Right') },
	{ key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Up') },
	{ key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Down') },

	-- ==================== ワークスペース ====================
	-- 登録済みワークスペースをあいまい検索で一覧表示して切り替え（＝「呼び出す」）
	-- 操作: Ctrl+e を押して離した後、w
	{ key = 'w', mods = 'LEADER', action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },

	-- 用途ごとのワークスペースへ一発切り替え（無ければ自動作成＝「登録」）
	-- 操作: Ctrl+e → p （論文執筆: ~/zkNote で起動）
	{ key = 'p', mods = 'LEADER', action = wezterm.action.SwitchToWorkspace {
		name = 'paper',
		spawn = { args = { 'wsl.exe', '--cd', '/home/dkojima/zkNote', '-d', 'Ubuntu-24.04' } },
	}},

	-- 操作: Ctrl+e → a （アプリ開発: ~ で起動。必要に応じてパスを変更）
	{ key = 'a', mods = 'LEADER', action = wezterm.action.SwitchToWorkspace {
		name = 'dev',
		spawn = { args = { 'wsl.exe', '--cd', '/home/dkojima', '-d', 'Ubuntu-24.04' } },
	}},

	-- 名前を入力してその場で新しいワークスペースを作成
	-- 操作: Ctrl+e → W (Shift+w)
	{ key = 'W', mods = 'LEADER', action = wezterm.action.PromptInputLine {
		description = wezterm.format {
			{ Attribute = { Intensity = 'Bold' } },
			{ Foreground = { Color = '#ae8b2d' } },
			{ Text = '新しいワークスペース名:' },
		},
		action = wezterm.action_callback(function(window, pane, line)
			if line and line ~= '' then
				window:perform_action(
					wezterm.action.SwitchToWorkspace { name = line },
					pane
				)
			end
		end),
	}},

	-- 前 / 次のワークスペースへ巡回
	-- 操作: Ctrl+e → [ または ]
	{ key = '[', mods = 'LEADER', action = wezterm.action.SwitchWorkspaceRelative(-1) },
	{ key = ']', mods = 'LEADER', action = wezterm.action.SwitchWorkspaceRelative(1) },

	-- ペインのサイズ調整モードへ入る（C-e r → 以降 h/j/k/l 連打で境界を移動 / Esc で終了）
	{ key = 'r', mods = 'LEADER', action = wezterm.action.ActivateKeyTable {
		name = 'resize_pane',
		one_shot = false,   -- モードを維持して連打を効かせる
	}},
}

-- ============================================================================
-- 4.1 キーテーブル（モード）: ペインのサイズ調整
-- ============================================================================
config.key_tables = {
	resize_pane = {
		-- h/j/k/l 連打で境界を少しずつ移動（1回あたり 3 セル）
		{ key = 'h', action = wezterm.action.AdjustPaneSize { 'Left', 3 } },
		{ key = 'l', action = wezterm.action.AdjustPaneSize { 'Right', 3 } },
		{ key = 'j', action = wezterm.action.AdjustPaneSize { 'Down', 3 } },
		{ key = 'k', action = wezterm.action.AdjustPaneSize { 'Up', 3 } },
		-- モード終了
		{ key = 'Escape', action = 'PopKeyTable' },
		{ key = 'Enter', action = 'PopKeyTable' },
	},
}

-- ============================================================================
-- 4.5 起動時のデフォルトレイアウト（左=通常CLI / 右=Claude）
-- ============================================================================
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
	-- 左ペイン（通常の WSL シェル）
	local tab, left_pane, window = mux.spawn_window {
		args = { 'wsl.exe', '--cd', '/home/dkojima', '-d', 'Ubuntu-24.04' },
	}

	-- 右ペインを 50% で分割し、そこで Claude を起動
	local right_pane = left_pane:split {
		direction = 'Right',
		size = 0.5,
		args = { 'wsl.exe', '--cd', '/home/dkojima', '-d', 'Ubuntu-24.04' },
	}
	-- claude を終了しても通常シェルが残るよう send_text で打ち込む方式にする
	right_pane:send_text 'claude\n'

	-- フォーカスは左の通常CLIに戻す
	left_pane:activate()

	window:gui_window():maximize()
end)

-- ============================================================================
-- 5. WezTermのステータスバー（右下）にモードを表示する
-- ============================================================================
wezterm.on("update-right-status", function(window, pane)
	local status = ""
	
	-- Leaderキーが押されて待機中の場合
	if window:leader_is_active() then
		status = " LEADER "
	end
	
	-- コピーモードなどの特殊モードに入っている場合
	local key_table = window:active_key_table()
	if key_table then
		status = status .. " " .. key_table .. " "
	end
	
	-- 現在のワークスペース名（左側に控えめな色で）＋モード表示（右側に目立つ色で）
	window:set_right_status(wezterm.format({
		{ Background = { Color = "#5c6d74" } },
		{ Foreground = { Color = "#FFFFFF" } },
		{ Text = "  " .. window:active_workspace() .. "  " },
		{ Background = { Color = "#ae8b2d" } },
		{ Foreground = { Color = "#000000" } },
		{ Text = status },
	}))
end)

-- ============================================================================
-- 最後に設定オブジェクトをWezTermに返す
-- ============================================================================
return config
