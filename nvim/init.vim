" File: ~/.config/nvim/init.vim

filetype plugin indent on


"Press Leader with both of my thumbs, and my fingers are always on home row
let g:mapleader = "\<Space>"

" Automatic installation vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif


" =============================================================================
" General settings {{{
" =============================================================================
syntax on " syntax highlighting on

set modelines=0
set background=dark " we plan to use a dark background
set noexrc " don't use local version of .(g)vimrc, .exrc
set cpoptions=aABceFsmq
"             |||||||||
"             ||||||||+-- When joining lines, leave the cursor
"             |||||||      between joined lines
"             |||||||+-- When a new match is created (showmatch)
"             ||||||      pause for .5
"             ||||||+-- Set buffer options when entering the
"             |||||      buffer
"             |||||+-- :write command updates current file name
"             ||||+-- Automatically add <CR> to the last line
"             ||||     when using :@r
"             |||+-- Searching continues at the end of the match
"             ||      at the cursor position
"             ||+-- A backslash has no special meaning in mappings
"             |+-- :write updates alternative file name
"             +-- :read updates alternative file name

set autoread " auto reload file when file being change

" Set file encoding
set encoding=utf-8
set fileencoding=utf-8
" Load filetype plugins/indent settings

set autochdir " always switch to the current file directory
set backspace=indent,eol,start " make backspace a more flexible
set ttyfast

set title                " change the terminal's title

" set backup (and swap) files into sperate directory
" set backup " make backup files
" set backupdir=~/.vim/backup " where to put backup files
" set directory=~/.vim/tmp " directory to place swap files in
set nobackup
set noswapfile

set clipboard+=unnamedplus

set fileformats=unix,dos,mac " support all three, in this order
set hidden " you can change buffers without saving
" (XXX: #VIM/tpope warns the line below could break things)
set iskeyword+=_,$,@,%,# " none of these are word dividers

" Add mouse support - cursor position, selection tabs.
" (Use shift to select text.)
" n = normal mode, i = insert, c = command (do i use), a = all
" set mouse=ni
set mouse=a
" Mouse popup menu
set mousemodel=popup
" Toggle mouse
map   <F7> <Esc>:set mouse=<CR>
map <S-F7> <Esc>:set mouse=nic<CR>

set noerrorbells " don't make noise
set whichwrap=b,s,h,l,<,>,~,[,] " everything wraps
"             | | | | | | | | |
"             | | | | | | | | +-- "]" Insert and Replace
"             | | | | | | | +-- "[" Insert and Replace
"             | | | | | | +-- "~" Normal
"             | | | | | +-- <Right> Normal and Visual
"             | | | | +-- <Left> Normal and Visual
"             | | | +-- "l" Normal and Visual (not recommended)
"             | | +-- "h" Normal and Visual (not recommended)
"             | +-- <Space> Normal and Visual
"             +-- <BS> Normal and Visual
" ignore these list file extensions
" Tab Complete Menu
set wildmenu " turn on command line completion wild style
set wildignore+=*.o,*~,.lo,*.dll,*.obj,*.swp,*.class,*.bak,*.exe,*.pyc,*.jpg,*.gif,*.png
set suffixes+=.in,.a

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo

set timeoutlen=350 " timeout when mapping keystrokes
set showfulltag " show full tag insert mode

" ================================ GVim =====================================

" Tab Bar Always On - so I know what I'm writing to.
" set showtabline=2
set laststatus=2 " always show the status line
set lazyredraw " do not redraw while running macros
set linespace=0 " don't insert any extra pixel lines
                 " betweens rows
set list " we do what to show tabs, to ensure we get them
         " out of my files
set listchars=trail:⋅,nbsp:⋅,tab:▸\ ,extends:# " show tabs and trailing
set matchtime=5 " how many tenths of a second to blink
                " matching brackets for
set nostartofline " leave my cursor where it was
set novisualbell " don't blink
set number " turn on line numbers
set numberwidth=5 " We are good up to 99999 lines
set report=0 " tell us when anything is changed via :...
set ruler " Always show current positions along the bottom
set scrolloff=10 " Keep 10 lines (top/bottom) for scope
set shortmess=aOstT " shortens messages to avoid 'press a key' prompt
set showcmd " show the command being typed
set showmatch " show matching brackets
set sidescrolloff=10 " Keep 5 lines at the size
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
"              | | | | |  |   |      |  |     |    |
"              | | | | |  |   |      |  |     |    + current
"              | | | | |  |   |      |  |     |       column
"              | | | | |  |   |      |  |     +-- current line
"              | | | | |  |   |      |  +-- current % into file
"              | | | | |  |   |      +-- current syntax in
"              | | | | |  |   |          square brackets
"              | | | | |  |   +-- current fileformat
"              | | | | |  +-- number of lines
"              | | | | +-- preview flag in square brackets
"              | | | +-- help flag in square brackets
"              | | +-- readonly flag in square brackets
"              | +-- rodified flag in square brackets
"              +-- full path to file in the buffer
set cursorline      " highlight current line
set cursorcolumn    " highlight the current column


" =============================================================================
" Plugins {{{
" =============================================================================

call plug#begin('~/.config/nvim/plugged')

" =============================================================================
" Appearance
" =============================================================================

" Solarized
Plug 'altercation/vim-colors-solarized'

" vim-airline
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
" {{{
  let g:airline_theme = 'solarized'
  let g:airline_powerline_fonts = 1
  let g:airline_exclude_preview = 1

  let g:airline_section_z = '%2p%% %2l/%L:%2v'
  let g:airline#extensions#branch#enabled = 1
  let g:airline#extensions#syntastic#enabled = 0
  let g:airline#extensions#whitespace#enabled = 0
  let g:airline#extensions#tabline#enabled = 0

  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_tab_nr = 1
  let g:airline#extensions#tabline#show_buffers = 1

  let g:airline#extensions#bufferline#enabled = 1
  let g:airline#extensions#bufferline#overwrite_variables = 1
  let g:bufferline_echo = 0

  " Tabline
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_buffers = 1
  let g:airline#extensions#tabline#show_tabs = 0
  let g:airline#extensions#tabline#buffer_idx_mode = 1
  let g:airline#extensions#tabline#fnamecollapse = 1
  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#extensions#tabline#show_tab_type = 0
  let g:airline#extensions#tabline#buffer_min_count = 2

  let g:airline#extensions#ale#enabled = 1

  nmap <leader>- <Plug>AirlineSelectPrevTab
  nmap <leader>= <Plug>AirlineSelectNextTab

" }}}

" Editorconfig
Plug 'editorconfig/editorconfig-vim'

" The NERD Tree:  A tree explorer plugin for vim
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Open NERDTree with Ctrl+n
map <C-n> :NERDTreeToggle<CR>

" =============================================================================
" Completion
" =============================================================================

" =============================================================================
" Languages
" =============================================================================

" ALE (Asynchronous Lint Engine)
Plug 'w0rp/ale'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" systemd service syntax
Plug 'Matt-Deacalion/vim-systemd-syntax'

" =============================================================================
" Git
" =============================================================================

" Fugitive: Git from within Vim
Plug 'tpope/vim-fugitive'
" {{{
  nnoremap <silent> <leader>gs :Gstatus<CR>
  nnoremap <silent> <leader>gd :Gdiff<CR>
  nnoremap <silent> <leader>gc :Gcommit<CR>
  nnoremap <silent> <leader>gb :Gblame<CR>
  nnoremap <silent> <leader>ge :Gedit<CR>
  nnoremap <silent> <leader>gE :Gedit<space>
  nnoremap <silent> <leader>gr :Gread<CR>
  nnoremap <silent> <leader>gR :Gread<space>
  nnoremap <silent> <leader>gw :Gwrite<CR>
  nnoremap <silent> <leader>gW :Gwrite!<CR>
  nnoremap <silent> <leader>gq :Gwq<CR>
  nnoremap <silent> <leader>gQ :Gwq!<CR>

  function! ReviewLastCommit()
    if exists('b:git_dir')
      Gtabedit HEAD^{}
      nnoremap <buffer> <silent> q :<C-U>bdelete<CR>
    else
      echo 'No git a git repository:' expand('%:p')
    endif
  endfunction
  nnoremap <silent> <leader>g` :call ReviewLastCommit()<CR>

  augroup fugitiveSettings
    autocmd!
    autocmd FileType gitcommit setlocal nolist
    autocmd BufReadPost fugitive://* setlocal bufhidden=delete
  augroup END
" }}}

" =============================================================================
" Misc
" =============================================================================

" Faster serching code using ag
Plug 'mileszs/ack.vim'
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Make commenting easier
Plug 'tpope/vim-commentary'

" SimpylFold
Plug 'tmhedberg/SimpylFold'

" Other plugins require curl
if executable("curl")
    " Gist: Post text to gist.github.
    " Webapi: Dependency of Gist-vim
    Plug 'mattn/webapi-vim' | Plug 'mattn/gist-vim'
    let g:gist_clip_command = 'xclip -selection clipboard'
    let g:gist_detect_filetype = 1
    let g:gist_show_privates = 1
    let g:gist_post_private = 1
    let g:gist_get_multiplefile = 1
endif

" Base16 colorscheme
Plug 'chriskempson/base16-vim'

filetype plugin indent on                   " required!
call plug#end()


" Solarized everywhere
if !has('nvim')
  " Must be first line to set vim, not vii
  set nocp
  " 256 color
  set t_Co=256
  set term=xterm-256color
else
  " Hack to get Ctrl+H working in NeoVim
  nmap <BS> <C-W>h
end
let g:solarized_termcolors=256
let g:solarized_termtrans=1
colorscheme solarized


" ========================== Text/Formatting Layout =========================
"
" Smart autoindenting when starting a new line
set autoindent
set smartindent

" Search
" Incremental Search - Searches begin immediately
set incsearch " BUT do highlight as you type you search phrase
set hlsearch "highlight search
set ignorecase
set shiftround " when at 3 spaces, and I hit > ... go to 4, not 5
set smartcase " if there are caps, go case-sensitive
set gdefault
set showmatch
set matchtime=1

" Use sane regexes
nnoremap / /\v
vnoremap / /\v

" Toggle the highlight search
"map <leader><space> :set hlsearch!<cr>
nmap <tab> %
vmap <tab> %

" set completeopt= " don't use a pop up menu for completions
set nowrap              " do not wrap line
set noswapfile
set linebreak
set formatoptions=croqnl1  " Automatically insert comment leader on return,
                           " and let gq format comments
set ignorecase  " case insensitive by default
set infercase   " case inferred by default

set textwidth=79  " lines longer than 79 columns will be broken
set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
set tabstop=4     " a hard TAB displays as 4 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

" Wrap whole words - but forces line break
" set wm=2
set matchpairs+=<:>
set vb t_vb= " Turn off the bell

" Show line number when print
set printoptions+=number:y

" Folding
set foldenable          " Turn on folding
set foldmarker={,}      " Fold C style code (only use this as default if you
                        " use a high foldlevel)
set foldmethod=marker   " Fold on the marker
set foldlevel=100       " Don't autofold anything (but I can still fold manually)
set foldopen=block,hor,mark,percent,quickfix,tag " what movements open folds
function! SimpleFoldText()
    return getline(v:foldstart).' '
endfunction
set foldtext=SimpleFoldText() " Custom fold text function (cleaner than default)

" ========================== Auto Command ===================================
" Automatically reload vimrc when it's saved
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

" Show Git diff in window split when commiting
"autocmd FileType gitcommit DiffGitCached | wincmd p

" Color Column (only on insert)
if exists("&colorcolumn")
     autocmd InsertEnter * set colorcolumn=79
     autocmd InsertLeave * set colorcolumn=""
endif

" ======================== Vim Mapping Keystroke ============================

" Type <Space>w to save file (a lot faster than :w<Enter>)
nnoremap <Leader>w :w<CR>

" sudo write
cmap ww w !sudo tee % > /dev/null

" Easy split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Don't using to arrow to moving
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Make Y behave like other capitals
map Y y$

" Disable search highlighting
nnoremap <silent> <Esc><Esc> :nohlsearch<CR><Esc>

" Keep search results at the center of screen
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" Select all text
noremap vA ggVG

" Open tig
nnoremap <Leader>gg :tabnew<CR>:terminal tig<CR>


" Copy & paste to system clipboard with <Space>p and <Space>y:
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

nnoremap <Leader>y "*y
nnoremap <Leader>p "*p
nnoremap <Leader>P "*P

" Clipboard for Linux
nnoremap yy yy"+yy
vnoremap y ygv"+y
nmap gp "+gP

" Enter visual line mode with <Space><Space>:
nmap <Leader><Leader> V

" Select all
map <Leader>a ggVG

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Mapping ; to : to quickly type command
nnoremap ; :

" Use Q for formatting the current paragraph (or selection)
vmap Q gq
nmap Q gqap

" map Esc to another key to quickly
" mapping Esc to jj
ino jj <esc>
cno jj <C-c>
vno v <esc>

" Use jk as <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

" Press i to enter insert mode, and ii to exit.
imap ii <Esc>

" Two semicolons are easy to type.
imap ;; <Esc>

" On gvim and Linux console Vim, you can use Alt-Space.
imap <M-Space> <Esc>

" Automatic retab and write
map <F12> :retab <CR> :w! <CR>


" paste to ix.io
noremap <silent> <leader>i :w !ix<CR>

" <Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>


" Inser New Line
map <s-enter> O<esc>
map <enter> o<esc>

" I can type :help on my own, thanks.
noremap <F1> <Esc>

" vimdiff as mergetool
map <silent> <leader>2 :diffget 2<CR> :diffupdate<CR>
map <silent> <leader>3 :diffget 3<CR> :diffupdate<CR>
map <silent> <leader>4 :diffget 4<CR> :diffupdate<CR>


" check file change every 4 seconds ('CursorHold')
" and reload the buffer upon detecting change
set autoread
au CursorHold * checktime

" https://github.com/neovim/neovim/issues/7002
set guicursor=

" End of ~/.vimrc
