"==============================================================================
" UNIFIED VIM CONFIGURATION
"==============================================================================
" Always set encoding at the very top of the file.
scriptencoding utf-8
" Modelines are a way to set file-specific options. See :help modeline.
" vim: set ts=8 sts=2 sw=2 tw=0 et:


"------------------------------------------------------------------------------
" Kaoriya Vim Distribution Specifics
"------------------------------------------------------------------------------
" Load site-local settings if they exist. This is a feature of Kaoriya Vim
" to allow system-wide configurations without modifying this user file.
if filereadable($VIM . '/gvimrc_local.vim')
  source $VIM/gvimrc_local.vim
  if exists('g:gvimrc_local_finish') && g:gvimrc_local_finish != 0
    finish
  endif
endif

" Source the default example vimrc file, unless disabled by the user.
if !exists('g:no_gvimrc_example') || g:no_gvimrc_example == 0
  source $VIMRUNTIME/gvimrc_example.vim
endif


"==============================================================================
" CORE VIM SETTINGS
"==============================================================================

" --- Filetype and Syntax ---
syntax on                      " Enable syntax highlighting.
filetype plugin indent on      " Enable filetype detection, plugins, and indentation.

" --- Encoding and Formats ---
set encoding=utf-8             " Set the internal encoding to UTF-8.
set fileformats=unix,dos,mac   " Automatically detect line endings.

" --- Command Line ---
set cmdheight=1                " Set command line height to 1.
set wildmenu                   " Enable enhanced command-line completion.
set wildmode=longest:full,list:full " Set completion mode.


"==============================================================================
" APPEARANCE
"==============================================================================

" --- Colors and Theme ---
colorscheme desert             " Set the colorscheme.

" --- UI Text and Numbers ---
set number                     " Show absolute line numbers.
set relativenumber             " Show relative line numbers for easier navigation.
set title                      " Set the window title to the current file name.
set ruler                      " Show cursor position in the status line.
set showcmd                    " Show partially typed commands.

" --- Highlighting ---
set hlsearch                   " Highlight all search matches.
set cursorline                 " Highlight the current line.
" Disable cursorline in insert mode for better performance.
autocmd InsertEnter * set nocursorline
autocmd InsertLeave * set cursorline


"==============================================================================
" EDITING BEHAVIOR
"==============================================================================

" --- Indentation ---
set tabstop=2                  " Number of spaces a tab counts for.
set shiftwidth=2               " Size of an indent.
set softtabstop=2              " Number of spaces for Tab key in insert mode.
set noexpandtab                " Use real tabs, not spaces.

" --- Search ---
set incsearch                  " Show search results as you type.
set ignorecase                 " Ignore case when searching.
set smartcase                  " Override 'ignorecase' if the pattern contains uppercase letters.
set wrapscan                   " Searches wrap around the end of the file.

" --- Backups and Undo ---
set nobackup                   " Do not create backup files.
set nowritebackup              " Do not create backups during writes.
set noswapfile                 " Do not create swap files.
set autoread                   " Automatically reload files changed outside of Vim.
" Keep undo history after closing a file.
if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undodir
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p')
  endif
endif

" --- General Behavior ---
set history=1000               " Number of commands to remember in history.
set backspace=indent,eol,start " Allow backspace to delete everything in insert mode.
set showmatch                  " Briefly jump to matching brackets.
set scrolloff=10               " Keep 10 lines visible above and below the cursor.
set sidescroll=10              " Keep 10 columns visible for horizontal scrolling.
set whichwrap=b,s,<,>,[,],h,l   " Allow specified keys to wrap across lines.
set ttimeoutlen=50             " Set timeout for key codes to 50ms (faster Esc response).
set iskeyword+=-               " Treat hyphenated words as a single word.
set belloff=all                " Disable all beeps.
set helplang=ja,en             " Prioritize Japanese for help language.


"==============================================================================
" KEY MAPPINGS
"==============================================================================

let mapleader = "\<Space>"      " Set the leader key to Space.

" --- Clipboard Workaround ---
" These mappings force yank/put operations to use the system clipboard ('+'
" register). This is a robust workaround for environments where
" 'set clipboard=unnamedplus' is unreliable.
vnoremap y  "+y
vnoremap Y  "+Y
nnoremap y  "+y
nnoremap p  "+p
nnoremap P  "+P
" Map Y to yank from cursor to the end of the line, like D or C.
nnoremap Y  "+y$

" --- Mode Switching ---
" Use 'jk' to exit insert and visual mode quickly.
imap jk <Esc>
vmap jk <Esc>

" --- Navigation and Searching ---
" Center the view on the cursor after search and movement.
nnoremap n nzz
nnoremap N Nzz
nnoremap j gjzz
nnoremap k gkzz
" Clear search highlight.
noremap <Leader>n :nohlsearch<CR>

" --- Text Manipulation ---
" Select all text.
noremap <Leader>a ggVG
" Go to the end of the line.
noremap <Leader>l $
" Go to the first non-blank character of the line.
noremap <Leader>h ^
noremap <Leader>k gg
noremap <Leader>j G
" Quickly surround a word with characters.
noremap \( i(<Esc>ea)<Esc>
noremap \{ i{<Esc>ea}<Esc>
noremap \[ i[<Esc>ea]<Esc>
noremap \$ i$<Esc>ea$<Esc>


"==============================================================================
" PLUGINS
"==============================================================================

" Load built-in matchit plugin for extended '%' matching.
if has('syntax') && has('eval')
  packadd! matchit
endif


"==============================================================================
" GUI-SPECIFIC SETTINGS
"==============================================================================

if has('gui_running')
  " --- GUI: Appearance ---
  if has('win32')
    " Set a modern programming font.
    " Other recommendations: Cica, Plemol JP, Cascadia Code.
    set guifont=HackGen_NF:h14
    " Set the line spacing for better readability.
    set linespace=2
    " For Kaoriya Vim: auto-detect width of ambiguous characters.
    if has('kaoriya')
      set ambiwidth=auto
    endif
    " Set the font used for printing.
    if has('printer')
      set printfont=MS_Mincho:h12:cSHIFTJIS
    endif
  endif
  
  " Set initial window size.
	"set columns=120
	"set lines=50
  " Customize terminal window colors within gVim.
  highlight Terminal guifg=lightgrey guibg=grey20

  " --- GUI: Behavior ---
  " Enable mouse support in all modes.
  set mouse=a
  " Hide the mouse pointer while typing.
  set mousehide
  " Hide the menu and toolbar for more screen space.
  set guioptions-=m
  set guioptions-=T

	set guifont=MS_Gothic:h13
  
  " Customize the IME cursor color.
  if has('multi_byte_ime')
    highlight CursorIM guibg=Purple guifg=NONE
  endif
endif
