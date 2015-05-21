" vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" start load vundles
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-fugitive'
Bundle 'klen/python-mode'
Bundle 'scrooloose/nerdtree'
Bundle 'Xuyuanp/nerdtree-git-plugin'
Bundle 'majutsushi/tagbar'
Bundle 'mileszs/ack.vim'
" end load vundles

" theme
"let g:solarized_termcolors=256
set background=dark
"colorscheme solarized

" turn filetype back on now that vundles are loaded
filetype on

" enable syntax highlighting
syntax enable

" set tabs to have 4 spaces
set ts=4

" indent when moving to the next line while writing code
set autoindent

" expand tabs into spaces
set expandtab

" when using the >> or << commands, shift lines by 4 spaces
set shiftwidth=4

" show the matching part of the pair for [] {} and ()
set showmatch

" enable all Python syntax highlighting features
let python_highlight_all = 1

" nerdtree style file tree in Explorer mode
let g:netrw_liststyle=3

" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

" Override go-to.definition key shortcut to Ctrl-]
let g:pymode_rope_goto_definition_bind = "<C-]>"

" Override run current python file key shortcut to Ctrl-Shift-e
let g:pymode_run_bind = "<C-S-e>"

" Override view python doc key shortcut to Ctrl-Shift-d
let g:pymode_doc_bind = "<C-S-d>"

" NERDTree
"au VimEnter *  NERDTree
nmap <F9> :NERDTreeToggle<CR>

" Tagbar 
nmap <F8> :TagbarToggle<CR>
let g:tagbar_autofocus=1

" Map ctrl-movement keys to window switching
map <C-Up> <C-w><Up>
map <C-Down> <C-w><Down>
map <C-Right> <C-w><Right>
map <C-Left> <C-w><Left>

" jump to definition with Ctrl+[
nnoremap <silent><Leader><C-]> <C-w><C-]><C-w>T

" Notes:
" - :E triggers the file Explorer
