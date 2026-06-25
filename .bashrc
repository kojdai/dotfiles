# ~/.bashrc: executed by bash(1) for non-login shells.
#
# =============================================================================
# 1. Basic Configuration
# =============================================================================

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# Set default editor
export EDITOR=nvim
export VISUAL=nvim
set -o vi

# =============================================================================
# 2. History Settings
# =============================================================================

# Don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=100000          # メモリ内に保持する件数（大きめ＝過去まで補完が効く）
export HISTFILESIZE=200000      # 履歴ファイルに残す件数（タイムスタンプ込みの行数）
shopt -s histappend
export HISTTIMEFORMAT="%Y-%m-%d %T "

# --- 履歴を dotfiles リポジトリに保管し、機種間で共有する ----------------------
# 本体は ~/dotfiles/history/bash_history（git管理 / .gitattributes で union merge）。
# 別マシンは dotfiles を clone するだけで HISTFILE が同じ場所を指し、履歴が復元される。
# リポジトリが無い環境では従来どおり ~/.bash_history にフォールバックする。
if [ -d "$HOME/dotfiles/.git" ]; then
	[ -d "$HOME/dotfiles/history" ] || mkdir -p "$HOME/dotfiles/history"
	export HISTFILE="$HOME/dotfiles/history/bash_history"
fi

# 機密が履歴（＝gitで公開され得る）に残らないよう除外する。
#   ・先頭にスペースを付けて打てば ignorespace で常に履歴から外せる（手動の保険）。
#   ・下記パターンに一致する行はメモリ/ファイルどちらにも保存されない（glob・大小区別）。
export HISTIGNORE='*password*:*Password*:*PASSWORD*:*passwd*:*secret*:*Secret*:*SECRET*:*token*:*Token*:*TOKEN*:*apikey*:*api_key*:*API_KEY*:*ANTHROPIC*:*OPENAI*:*GITHUB_TOKEN*:*AWS_SECRET*:*AWS_ACCESS_KEY*:*PRIVATE_KEY*:*--token*:*--password*:*curl*|*bash*:*curl*|*sh*:*wget*|*bash*:*wget*|*sh*'

# 各コマンド後に履歴ファイルへ追記（複数シェル・突然の終了でも取りこぼさない）。
case "${PROMPT_COMMAND:-}" in
	*'history -a'*) ;;
	*) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

# histsync — 履歴を dotfiles リポジトリへ commit/push して機種間で同期する。
# 関数にしているのは history -a で「いま開いているシェル」の履歴も確実に書き出すため。
histsync() {
	history -a
	local dot="$HOME/dotfiles"
	[ -d "$dot/.git" ] || { echo "histsync: $dot は git リポジトリではありません" >&2; return 1; }
	git -C "$dot" add history/bash_history
	if ! git -C "$dot" diff --cached --quiet; then
		git -C "$dot" commit -q -m "history: sync from $(hostname) $(date '+%F %T')"
	fi
	# 他マシン分を取り込み（union merge で衝突せず両者の行を残す）→ 送信
	git -C "$dot" pull --no-edit -q || { echo "histsync: pull に失敗（要確認）" >&2; return 1; }
	git -C "$dot" push -q && echo "histsync: 同期しました → origin"
}

# =============================================================================
# 3. Shell Options
# =============================================================================

shopt -s checkwinsize
shopt -s globstar
shopt -s autocd

# =============================================================================
# 4. Prompt Settings
# =============================================================================

case "$TERM" in
	xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
	PS1='\[\033[01;32m\]\$\[\033[00m\] '
else
	PS1='\$ '
fi
unset color_prompt

# =============================================================================
# 5. Environment Variables & PATH
# =============================================================================

# Base directories
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Custom tools
export PATH="/mnt/c/Users/rsdlab/spresenseenv/usr/bin/:$PATH"
export PATH="/usr/local/gcc-arm-none-eabi-7-2018-q2-update/bin:$PATH"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"

export PATH

# =============================================================================
# 6. Alias & Functions
# =============================================================================

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto --group-directories-first'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# Common ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Utilities
alias update='sudo apt update && sudo apt upgrade -y'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# WSL & App specific
alias open='explorer.exe'
alias exp='explorer.exe .'
alias pdf='explorer.exe *pdf'
# nvim はネイティブ Linux 版(/usr/local/bin -> /opt/nvim-linux-x86_64)を使う。
# ※ 旧 alias は /mnt/c (Windows FS, drvfs) 上の nvim を指しており、ランタイムを
#   WSL→Windows 境界越しに読むため起動が約2.4秒と激遅だった。alias を外すと
#   PATH 上の /usr/local/bin/nvim（ext4・約0.3秒）が使われる。
# alias nvim='/mnt/c/Users/kojda/.local/bin/nvim'

# vim と打ったらネイティブ Linux 版 nvim を開く
alias vim='nvim'
alias vi='nvim'

# Load custom aliases if file exists
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# =============================================================================
# 7. Keybindings
# =============================================================================

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
bind '"\C-e": edit-and-execute-command'

# =============================================================================
# 8. fzf Settings
# =============================================================================

export FZF_DEFAULT_OPTS='--bind=j:down,k:up'

# ff: fzf open file in vim, or cd into directory
ff() {
	local sel
	sel=$(ls | fzf) || return
	if [ -d "$sel" ]; then
		cd "$sel"
	elif [ -f "$sel" ]; then
		vim "$sel"
	fi
}

# =============================================================================
# 9. Zettelkasten (zk) Settings
# =============================================================================

# Note: Adjust this path if you want to share the folder directly with Windows (e.g., /mnt/c/Users/...)
export ZK_NOTEBOOK_DIR="$HOME/zkNote"

# zf: fzf search and edit note (displays 'filename | title')
#     一覧は作成時間の新しい順（--sort created-）で表示。
zf() {
	local notes sel file fullpath
	notes=$(zk list --no-pager --sort created- --format "{{path}} | {{title}}" "$@")

	if [ -z "$notes" ]; then
		echo -e "\e[33mNo notes found\e[0m"
		return
	fi

	sel=$(echo "$notes" | fzf)
	[ -z "$sel" ] && return

		# Extract filename by removing everything after the pipe
		file=$(echo "$sel" | sed 's/ *|.*//')
		fullpath="$ZK_NOTEBOOK_DIR/$file"

		nvim "$fullpath"
		zk index > /dev/null 2>&1
	}

# zff: full-text search inside notes (type to search note CONTENTS) and edit
#      zf はファイル名、zff は本文（中身の文字列）を検索する。
#      全 .md の一致行(file:line:text)を出し、fzf で打ちながら絞り込む。
#      スペース区切りは AND 検索（例: 学習 転移 → 両方を含む行）。
#      ripgrep(rg) があれば使い、無ければ grep にフォールバックする。
#      ※ この関数内だけ j/k は文字入力に使うため、移動は ↑↓ または Ctrl-n / Ctrl-p。
zff() {
	local sel file line
	# 一覧は file:line:text 形式に統一（rg は --no-column）。本文列(3..)のみ照合。
	# プレビューは rg 優先、無ければ grep。選択中行(+{2})を中央に表示。
	sel=$(
		{ if command -v rg >/dev/null 2>&1; then
			rg --line-number --no-heading --color=never --smart-case --type md '.' "$ZK_NOTEBOOK_DIR"
		  else
			grep -rIn --include='*.md' '.' "$ZK_NOTEBOOK_DIR"
		  fi; } \
		| FZF_DEFAULT_OPTS='' fzf \
			--delimiter ':' --nth '3..' \
			--preview 'rg --pretty --context 3 --color=always --smart-case -- {q} {1} 2>/dev/null || grep -n -C3 -- {q} {1} 2>/dev/null || true' \
			--preview-window 'down,50%,+{2}-/2'
	) || return
	[ -z "$sel" ] && return

	file=$(echo "$sel" | cut -d':' -f1)
	line=$(echo "$sel" | cut -d':' -f2)
	if [ -f "$file" ]; then
		nvim "+$line" "$file"
		zk index > /dev/null 2>&1
	fi
}

# _zk_new_edit <dir> <default-title> [title words...]
#   zk new でノートを作成→nvim で編集。zk はテンプレートを書き込んでから開くため、
#   何も書かず終了するとテンプレ入りの空ノートが残る。編集前後で内容(md5)を比較し、
#   変化が無ければ（＝何も書かなかったら）ファイルを破棄する。
#   「nvim と打って :q しただけ」と同じ挙動にする。
_zk_new_edit() {
	local dir="$1" deftitle="$2"; shift 2
	local f before after
	f=$(zk new "$ZK_NOTEBOOK_DIR/$dir" --title "${*:-$deftitle}" --print-path) || return
	[ -z "$f" ] && return
	before=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1)
	nvim "$f"
	# 編集中にユーザー自身が削除した場合は何もしない
	[ -f "$f" ] || { zk index > /dev/null 2>&1; return; }
	after=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1)
	if [ "$before" = "$after" ]; then
		rm -f "$f"
		echo -e "\e[33m空のノートを破棄しました: $(basename "$f")\e[0m"
	fi
	zk index > /dev/null 2>&1
}

# zn: create a Fleeting note in inbox/ (title optional: zn こうせいくんへ)
zn() { _zk_new_edit inbox     Fleeting   "$@"; }

# zl: create a Literature note in lit/ (出典付き要約)
zl() { _zk_new_edit lit       Literature "$@"; }

# zp: create a Permanent note in permanent/ (自分の言葉・1ノート1アイデア)
zp() { _zk_new_edit permanent Permanent  "$@"; }

# zi: review the Inbox (fleeting notes) interactively, then re-index
zi() {
	zk edit --interactive inbox "$@"
	zk index > /dev/null 2>&1
}

# zb: pick a note and show its backlinks (notes linking to it)
zb() {
	local sel file
	sel=$(zk list --no-pager --format "{{path}} | {{title}}" "$@" | fzf) || return
	[ -z "$sel" ] && return
	file=$(echo "$sel" | sed 's/ *|.*//')
	echo -e "\e[36m== Backlinks to: $file ==\e[0m"
	zk list --no-pager --link-to "$ZK_NOTEBOOK_DIR/$file" --format "{{path}} | {{title}}"
}

# zo: list orphan notes (no inbound links == まだ繋がっていないノート)
zo() {
	zk list --no-pager --orphan --sort created- --format "{{path}} | {{title}}" "$@"
}

# zd: open or create today's daily note with default title
zd() {
	local today filepath
	today=$(date +"%Y-%m-%d")
	filepath="$ZK_NOTEBOOK_DIR/$today.md"

	mkdir -p "$ZK_NOTEBOOK_DIR"

	if [ ! -f "$filepath" ]; then
		echo "# Daily Journal ($today)" > "$filepath"
	fi

	nvim "$filepath"
	zk index > /dev/null 2>&1
}

# zg: Full-text search inside notes and edit
zg() {
	if [ -z "$1" ]; then
		echo -e "\e[33mUsage: zg <keyword>\e[0m"
		return
	fi

	local match file
	# grep with line numbers (recurse into inbox/lit/permanent), pass to fzf
	match=$(grep -rn --include="*.md" "$1" "$ZK_NOTEBOOK_DIR" | fzf)
	[ -z "$match" ] && return

		# Extract filepath before the first colon
		file=$(echo "$match" | cut -d':' -f1)

		if [ -f "$file" ]; then
			nvim "$file"
			zk index > /dev/null 2>&1
		fi
	}

# zr: fzf search and remove note with confirmation (using rm -i)
zr() {
	local notes sel file fullpath
	notes=$(zk list --no-pager --format "{{path}} | {{title}}" "$@")

	if [ -z "$notes" ]; then
		echo -e "\e[33mNo notes found\e[0m"
		return
	fi

	sel=$(echo "$notes" | fzf)
	[ -z "$sel" ] && return

	file=$(echo "$sel" | sed 's/ *|.*//')
	fullpath="$ZK_NOTEBOOK_DIR/$file"

	if [ -f "$fullpath" ]; then
		rm -i "$fullpath"
		zk index > /dev/null 2>&1
	fi
}

# =============================================================================
# 10. Completions & Initializations
# =============================================================================

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Bash Completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# NVM Load
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Deno Load
[ -s "$DENO_INSTALL/env" ] && . "$DENO_INSTALL/env"
[ -f "$HOME/.local/share/bash-completion/completions/deno.bash" ] && source "$HOME/.local/share/bash-completion/completions/deno.bash"
