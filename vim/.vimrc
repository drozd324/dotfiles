set nocompatible
syntax enable
filetype plugin on

set nowrap
set tabstop=4
set shiftwidth=4
set viminfo+=<1000
set mouse=a

" true-color support (only active with set termguicolors)
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set background=dark
set t_Co=256

set path+=**
set wildmenu
