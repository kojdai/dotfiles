# ~/.bashrc: executed by bash(1) for non-login shells.
#
# =============================================================================
# # Basic Configuration
# =============================================================================

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# Set default editor
export EDITOR=nvim
export VISUAL=nvim

# =============================================================================
# # History Settings
# =============================================================================

# Don't put duplicate lines or lines starting with space in the history.
# Erase duplicates across the entire history file.
export HISTCONTROL=ignoreboth:erasedups

# Set history size
export HISTSIZE=10000
export HISTFILESIZE=20000

# Append to the history file, don't overwrite it
shopt -s histappend

# Save history with timestamp
export HISTTIMEFORMAT="%Y-%m-%d %T "

# =============================================================================
# # Shell Options
# =============================================================================

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# cd without typing 'cd'
shopt -s autocd

# =============================================================================
# # Prompt Settings
# =============================================================================

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Set the prompt
if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\$\[\033[00m\] '
else
    PS1='\$ '
fi
unset color_prompt

# =============================================================================
# # Alias Settings
# =============================================================================

# Enable color support of ls and also add handy aliases
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

# System update alias (run this manually when needed)
alias update='sudo apt update && sudo apt upgrade -y'

# WSL specific aliases
alias open='explorer.exe'
alias exp='explorer.exe .'
alias pdf='explorer.exe *pdf'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Application specific aliases
alias nvim='/mnt/c/Users/rsdlab/.local/bin/nvim'

# Load custom aliases if file exists
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi
# =============================================================================
# # Environment Variables
# =============================================================================

# Add user's private bin directories to PATH
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Custom PATH entries
PATH="/mnt/c/Users/rsdlab/spresenseenv/usr/bin/:$PATH"
PATH="$PATH:/usr/local/gcc-arm-none-eabi-7-2018-q2-update/bin"

# Deno
export DENO_INSTALL="$HOME/.deno"
PATH="$DENO_INSTALL/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"

export PATH

# =============================================================================
# # Keybindings
# =============================================================================

# History search backward/forward with Ctrl-P/Ctrl-N
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# Edit command line in $EDITOR with Ctrl-E
bind '"\C-e": edit-and-execute-command'

# =============================================================================
# # Completions and Initializations
# =============================================================================

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Bash Completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# NVM (Node Version Manager)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Deno completion - NOTE: The original path seemed incorrect.
# If you have deno completion installed, you may need to adjust the path below.
# [ -s "$HOME/.deno/completion/deno.bash" ] && source "$HOME/.deno/completion/deno.bash"
