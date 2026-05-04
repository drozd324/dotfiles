set nowrap
set tabstop=4
set shiftwidth=4
set viminfo+=<1000

" This is only necessary if you use "set termguicolors".
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" fixes glitch? in colors when using vim with tmux
set background=dark
set t_Co=256

set mouse=a
set nocompatible
syntax enable
filetype plugin on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Search down into subfolders, Provides tab completion 
set path+=**

"Display all matching files when we tab complete 
set wildmenu
