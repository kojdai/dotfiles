"When started as "evim", evim.vim will already have done these settings, bail
"out.
if v:progname =~? "evim"
  finish
endif

"Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		"do not keep a backup file, use versions instead
else
  set backup		"keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	"keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  "Switch on highlighting the last used search pattern.
  set hlsearch
endif

"Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  "For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

"Add optional packages.
"
"The matchit plugin makes the % command work better, but it is not backwards
"compatible.
"The ! means the package won't be loaded right away but when plugins are
"loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

"show line relative numbers"
set relativenumber
"incremental search:cursor moves while typing in the search box"
set incsearch
"allow to delete indent, line break, start with BackSpace"
set backspace=indent,eol,start
"yank to system clipboard"
set clipboard=unnamedplus
"keep last 200 cmd/search patterns in history"
set history=200
"show cursor position (line,column) in lower right corner"
set ruler
"show partially typed commands in status line"
set showcmd
set ttimeout
"making Esc respond faster"
set ttimeoutlen=100
"disable octal interpretation for numbers starting with
set nrformats-=octal
"enable syntax highlighe"
syntax enable
"enable filetype detection, plugins, and indent"
filetype plugin indent on
"use 'jk' to exit insert mode"
imap jk <Esc>
"use '\(' to wrap word with ()"
:map \( i(<Esc>ea)<Esc>
"use '\{' to wrap word with {}"
:map \{ i{<Esc>ea}<Esc>
"use '\$' to wrap word with $$"
:map \$ i$<Esc>ea$<Esc>
"enable matchit plugin: extend % to match HTML tags, if/else/endif, etc."
packadd! matchit
"set horizontal scroll offset to 10 characters"
:set sidescroll=10
"allow specified keys to move across line boundaries"
:set whichwrap=b,s,<,>,[,],h,l
"display invisible characters (tabs, spaces, line endings, etc.)"
:set list
"display tab as ->"
:set listchars=tab:>-,trail:-
"Define what characters are considered part of a keyword for word-based commands"
:set iskeyword=@,48-57,_,192-255,-
"set tab size as 2"
:set tabstop=2
"set leader key as Space key"
let mapleader = "\<Space>"
"select all"
nmap <Leader>a ggVG
"move to head of line with Space + h"
nmap <Leader>h 0
"move to head of line with Space + l"
nmap <Leader>l $
" emphasize cursorline"
:set cursorline
:highlight CursorLine cterm=NONE ctermfg=white ctermbg=DarkGray
nnoremap j gj
nnoremap k gk
" disable swp file"
set noswapfile
" disable backup file"
set nobackup
" disable undo file"
set noundofile
" disable beep sound"
set belloff=all
