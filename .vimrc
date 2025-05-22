" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

set relativenumber "show line relative numbers"
set incsearch "incremental search:cursor moves while typing in the search box"
set backspace=indent,eol,start "allow to delete indent, line break, start with BackSpace"
set clipboard=unnamedplus "yank to system clipboard"
set history=200 "keep last 200 cmd/search patterns in history"
set ruler "show cursor position (line,column) in lower right corner"
set showcmd "show partially typed commands in status line"
set ttimeout
set ttimeoutlen=100 "making Esc respond faster"
set nrformats-=octal "disable octal interpretation for numbers starting with
syntax on "enable syntax highlighe"
filetype plugin indent on "enable filetype detection, plugins, and indent"
imap jk <Esc> " use 'jk' to exit insert mode"
:map \( i(<Esc>ea)<Esc> " use '\(' to wrap word with ()"
:map \{ i{<Esc>ea}<Esc> " use '\{' to wrap word with {}"
:map \$ i$<Esc>ea$<Esc> " use '\$' to wrap word with $$"
packadd! matchit " enable matchit plugin: extend % to match HTML tags, if/else/endif, etc."
:set sidescroll=10 " set horizontal scroll offset to 10 characters"
:set whichwrap=b,s,<,>,[,],h,l " allow specified keys to move across line boundaries"
:set list " display invisible characters (tabs, spaces, line endings, etc.)"
:set listchars=tab:>-,trail:- " display tab as ->"
:set iskeyword=@,48-57,_,192-255,- " Define what characters are considered part of a keyword for word-based commands"

