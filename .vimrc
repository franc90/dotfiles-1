"+----------+
"| SETTINGS |
"+----------+

" Options
set backspace=indent,eol,start " Allow backspacing over everything in insert mode
set cursorline                 " Highlight the current line of the cursor
set display=truncate           " Show @@@ in the last line if it is truncated
set expandtab                  " Use spaces when tab is inserted
set history=200                " Keep 200 lines of command line history
set incsearch                  " Highlight match while typing search pattern
set laststatus=2               " Always show status line
set mouse=a                    " Enable mouse in all modes
set nocompatible               " Use Vim settings, rather than Vi settings
set noshowmode                 " Hide mode infomation on the last line
set nrformats-=octal           " Do not recognize octal numbers for Ctrl-A and Ctrl-X
set number                     " Print the line number
set relativenumber             " Show relative line number
set ruler                      " Show the cursor position all the time
set scrolloff=1                " Minimum number of lines above and below cursor
set shiftwidth=4               " Number of spaces to use for indent step
set showcmd                    " Display incomplete commands
set splitbelow                 " New window from split is below the current one
set splitright                 " New window is put right of the current one
set tabstop=4                  " Number of spaces that Tab in file uses
set ttimeout                   " Time out for key codes
set ttimeoutlen=100            " Wait up to 100ms after Esc for special key
set wildmenu                   " Display completion matches in a status line
set hidden                     " Allow loading a buffer in a window that currently has a modified buffer
filetype plugin indent on      " Enable file type detection
syntax on                      " Turn on syntax highlighting

" Jumps to the last known position in a file after opening it
function! ResCur()
    if line("'\"") <= line("$")
        normal! g`"
        return 1
    endif
endfunction
augroup resCur
    autocmd!
    autocmd BufWinEnter * call ResCur()
augroup END

" Cursor line
hi CursorLine cterm=none ctermbg=060

" Change cursor shape in different modes
let &t_EI = "\033[2 q" " NORMAL  █
let &t_SI = "\033[5 q" " INSERT  |
let &t_SR = "\033[3 q" " REPLACE _

" Split separator
set fillchars+=vert:\│
hi VertSplit cterm=none ctermbg=none

"+-------------+
"| KEY MAPPING |
"+-------------+

" Don't use Ex mode, use Q for formatting.
map Q gq

" Save as root
cmap W w !sudo /usr/bin/tee > /dev/null %

" Quick buffer switching
nnoremap <C-t> :ls<CR>:buffer<Space>
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" Copy and paste with system clipboard
vmap <C-c> "+y
vmap <C-v> c<ESC>"+p
imap <C-v> <ESC>"+pa

"+---------+
"| PLUGINS |
"+---------+

" Auto install plugin manager
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins list
call plug#begin('~/.vim/plugged')
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'Yggdroot/indentLine'
Plug 'bling/vim-bufferline'
Plug 'christoomey/vim-tmux-navigator'
Plug 'itchyny/lightline.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'justinmk/vim-sneak'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'
call plug#end()

" Conquer of Completion
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" NERDTree
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" indentLine
let g:indentLine_char = '│'
let g:indentLine_color_term = 240

