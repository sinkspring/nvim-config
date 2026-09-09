" ================================
" Basic Settings
" ================================

" Clipboard integration
set clipboard=unnamedplus

" Completion menu behavior
set completeopt=noinsert,menuone,noselect

" Visual enhancements
set cursorline              " Highlight current line
set number                  " Show line numbers
set cc=80                   " Column guide at 80 characters
set title                   " Show file title in terminal

" Editing behavior
set hidden                  " Allow switching buffers without saving
set autoindent             " Auto-indent new lines
set mouse=a                " Enable mouse support
set inccommand=split       " Show live preview of substitutions

" Window behavior
set splitbelow splitright  " More natural split directions

" Performance
set ttyfast                " Faster scrolling

" File type detection
filetype plugin indent on
syntax on

" Interface enhancements
set wildmenu               " Enhanced command completion
set spell                  " Enable spell checking

" ================================
" Plugin Management
" ================================

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Color scheme
Plug 'maxmx03/solarized.nvim'

" Status line and interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'

" File management
Plug 'scrooloose/nerdtree'

" Code editing
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'sheerun/vim-polyglot'

" Code intelligence
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Git integration
Plug 'tpope/vim-fugitive'

call plug#end()

" ================================
" Plugin Configuration
" ================================

" Color scheme
lua require('solarized').setup({ autoload = true })
colorscheme solarized

" Airline configuration
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#left_sep=' '
let g:airline#extensions#tabline#left_alt_sep='|'
let g:airline#extensions#tabline#formatter='unique_tail'

" NERDTree configuration
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1

" ================================
" Key Mappings
" ================================

" Set leader key
let mapleader = ","

" Quick file explorer
nnoremap <leader>n :NERDTreeToggle<CR>

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
