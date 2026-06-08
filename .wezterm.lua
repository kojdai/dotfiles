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
}

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
	
	-- 右下に目立つ色（黄色背景に黒文字）で表示
	window:set_right_status(wezterm.format({
		{ Background = { Color = "#ae8b2d" } },
		{ Foreground = { Color = "#000000" } },
		{ Text = status },
	}))
end)

-- ============================================================================
-- 最後に設定オブジェクトをWezTermに返す
-- ============================================================================
return config
