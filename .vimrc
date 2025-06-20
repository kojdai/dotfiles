"==================================================
" Initialization
"==================================================

" Exit if started as 'evim', as evim.vim will already have set these options
if v:progname =~? "evim"
  finish
endif


"==================================================
" Backup and Undo Settings
"==================================================

" Do not keep a backup file, use versions instead (for VMS)
if has("vms")
  set nobackup
else
  " Keep a backup file (restore to previous version)
  set backup
  " Keep an undo file (undo changes after closing)
  if has('persistent_undo')
    set undofile
  endif
endif


"==================================================
" Search Settings
"==================================================

" Highlight the last used search pattern
if &t_Co > 2 || has("gui_running")
  set hlsearch
endif

" Show relative line numbers for easier navigation
set relativenumber

" Show absolute line numbers
set number

" Enable incremental search (cursor moves as you type)
set incsearch

" Wrap search around the end of the file
set wrapscan

" Ignore case in search patterns
set ignorecase

" Override ignorecase if search pattern contains uppercase letters
set smartcase

" Enable faster scrolling
set ttyfast


"==================================================
" Editing Behavior
"==================================================

" Allow backspace to delete indent, line breaks, and start of insert
set backspace=indent,eol,start

" Use system clipboard for yank, delete, change and put operations
set clipboard=unnamedplus

" Keep the last 200 commands/search patterns in history
set history=200

" Show the cursor position (line, column) in the status line
set ruler

" Show partially typed commands in the status line
set showcmd

" Enable key code timeout
set ttimeout

" Set key code timeout length to 100ms for faster Esc response
set ttimeoutlen=100

" Disable octal number interpretation for numbers starting with 0
set nrformats-=octal

" Enable automatic indentation
set autoindent

" Briefly jump to matching bracket when inserting one
set showmatch

" Enable smart auto-indenting when starting a new line
set smartindent

" Automatically wrap lines at 80 characters
set textwidth=80



"==================================================
" Syntax and Filetype
"==================================================

" Enable syntax highlighting

syntax enable

" Color Scheme
autocmd ColorScheme * highlight Comment ctermfg=2 guifg=#008800
colorscheme darkblue


" Enable filetype detection, plugins, and indentation
filetype plugin indent on

" Set file encoding to UTF-8
set encoding=utf-8

" Try Unix, then DOS, then Mac line endings when reading files
set fileformats=unix,dos,mac


"==================================================
" Plugin and Package Management
"==================================================

" Load the matchit plugin to improve '%' matching (for HTML tags, if/else/endif, etc.)
if has('syntax') && has('eval')
  packadd! matchit
endif


"==================================================
" Key Mappings
"==================================================

" Use 'jk' to exit insert mode
imap jk <Esc>

" Use full-width 'ｊｋ' to exit insert mode
imap ｊｋ <Esc>

" Use 'jk' to exit visual mode
vmap jk <Esc>

" Wrap word with ()
:map \( i(<Esc>ea)<Esc>

" Wrap word with {}
:map \{ i{<Esc>ea}<Esc>

" Wrap word with []
:map \[ i[<Esc>ea]<Esc>

" Wrap word with $$
:map \$ i$<Esc>ea$<Esc>

" Set the leader key to Space
let mapleader = "\<Space>"

" Select all text
nmap <Leader>a ggVG

" Move to the beginning of the line with <Leader>h
nmap <Leader><Leader>h 0

" Move to the head chalactor of the line with <Leader><Leader>h"
nmap <Leader>h ^

" Move to the end of the line with <Leader>l
nmap <Leader>l $

" Makes "Y" behave like "D" and "C": yanks (copies) from the cursor to the end of the line.
nnoremap Y y$

"==================================================
" Display and Interface
"==================================================

" Set horizontal scroll offset to 10 characters
set sidescroll=10

" Allow certain keys to move across line boundaries
set whichwrap=b,s,<,>,[,],h,l

" Display invisible characters (tabs, trailing spaces, etc.)
set list

" Display tab as '>-', trailing spaces as '-'
set listchars=tab:>-,trail:-

" Highlight the line where the cursor is located
set cursorline

" Set cursor line highlight color
highlight CursorLine cterm=NONE ctermfg=white ctermbg=DarkGray

" Define what characters are considered part of a keyword
set iskeyword=@,48-57,_,192-255,-

" manual with ja
set helplang=ja,en

"==================================================
" Tabs and Indentation
"==================================================

" Use spaces instead of tabs for indentation
set expandtab

" Number of spaces that a <Tab> in the file counts for
set tabstop=2

" Number of spaces to use for each step of (auto)indent
set shiftwidth=2

" Number of spaces a <Tab> counts for while performing editing operations
set softtabstop=2


"==================================================
" Navigation Improvements
"==================================================

" Move down by display lines (wrap-aware)
nnoremap j gj

" Move up by display lines (wrap-aware)
nnoremap k gk


"==================================================
" File Handling and Performance
"==================================================

" Disable swap files
set noswapfile

" Automatically reload file if changed outside Vim
set autoread


"==================================================
" Miscellaneous
"==================================================

" Disable all beep sounds
set belloff=all

" Set the terminal window title to the file name
set title

