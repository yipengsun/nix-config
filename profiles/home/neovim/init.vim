"""""""""""
" General "
"""""""""""

" Disable vi compatible mode
set nocp

" Set to auto read when a file is changed from the outside
set autoread

" Restore cursor position
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Aggregate all .swp files in a single directory
set directory=$HOME/.tmp/vim

" Mouse support
if has('mouse')
    set mouse=a
endif

" Filecodings settings
set enc=utf-8
set fencs=utf-8,cp936,ucs-bom,gb18030,gbk,gb2312

" Backup settings
set nobackup
set nowritebackup

" Current directory settings
set autochdir
set sessionoptions-=curdir

" Folding settings
set foldenable
set foldmethod=syntax
set foldcolumn=3

" Backspace settings
set backspace=eol,start,indent

" Tab settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab

" Live substitution preview
set inccommand=nosplit

" Use internal diff tool
set diffopt=filler,internal,algorithm:histogram,indent-heuristic

" Enable filetypes and syntax
filetype plugin indent on
syntax on


"""""""""""""
" Interface "
"""""""""""""

" UI settings
set shortmess=atI
set showcmd

" Statusbar settings
set cmdheight=1
set laststatus=2

" Cursor settings
set so=7
set gcr=n-c-v-i:block
set gcr=a:blinkon0
set novisualbell
au InsertEnter * set cursorline
au InsertLeave * set nocursorline
"au InsertEnter * set cursorcolumn
"au InsertLeave * set nocursorcolumn

" Linebreak settings
set linebreak
set iskeyword+=_,$,@,%,#,-
set wrap

" Show relative line number by default
set number
set rnu

" Turn on wildmenu
set wildmenu
set wildmode=longest:full,full

" Disable spell check for CJK chars
set spelllang+=cjk


"""""""""""""
" Movements "
"""""""""""""

" Disable page-scolling with CTRL-F, CTRL-B, CTRL-U, etc
"nnoremap <C-f> <NOP>  " taken bytelescope
nnoremap <C-b> <NOP>
"nnoremap <C-u> <NOP>  " taken by nvim-dap


""""""""""
" Search "
""""""""""

" Basic matching settings
set magic
set showmatch

" Hilight search results
set hlsearch

" Ignore case when searching
set ignorecase
set smartcase

" Incremental match when searching
set incsearch

" Split to the right
set splitright


"""""""""""
" Mapping "
"""""""""""

" Disable Ex mode
nnoremap Q <NOP>

" Tab navigation
nnoremap tp :tabprevious<CR>
nnoremap tn :tabnext<CR>
nnoremap to :tabnew
nnoremap tc :tabclose<CR>

" Move among windows with arrow keys
nnoremap <C-DOWN> <C-w>j
nnoremap <C-UP> <C-w>k
nnoremap <C-LEFT> <C-w>h
nnoremap <C-RIGHT> <C-w>l

" Indent text in visual/normal mode via tab/shift-tab
nnoremap <TAB> v>
nnoremap <S-TAB> v<
vnoremap <TAB> >gv
vnoremap <S-TAB> <gv

" Auto close pairs in visual mode
vnoremap ( s()<ESC>P<RIGHT>%
vnoremap [ s[]<ESC>P<RIGHT>%
vnoremap { s{}<ESC>P<RIGHT>%
vnoremap < s<><ESC>P<RIGHT>%
vnoremap ` s``<ESC>P<RIGHT>%
vnoremap ' s''<ESC>P<RIGHT>%
vnoremap " s""<ESC>P<RIGHT>%

" Folding switch
nnoremap <silent><SPACE> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

" Clear search highlight
nnoremap <silent><C-k> <ESC>:nohl<CR>

" Set CTRL-C, CTRL-V, CTRL-X
vnoremap <C-c> "+y
inoremap <silent><C-v> <ESC>:set paste<CR>"+gp<ESC>:set nopaste<CR>
vnoremap <C-x> "+x

" Function-keys mapping
nnoremap <F1> <NOP>
vnoremap <F1> <NOP>
inoremap <silent><F1> <C-R>=strftime("%F")<BAR><CR>

" Auto copy text under mouse-selection
vnoremap <LeftRelease> "*ygv

" Insert a hard tab
inoremap <F5> <C-V><Tab>

" Toggle linenumber mode (relative, absolute)
func! ToggleNuMode()
    if(&rnu == 1)
        set nornu
    else
        set rnu
    endif
endfunc
nnoremap <silent><C-l> :call ToggleNuMode()<CR>

" Toggle spell check
func! ToggleSpellCheck()
    set spelllang=en_us
    let spl_status=&spell
    if &spell
        let spl_status="nospell"
        echo "Spell Check is turned off."
    else
        let spl_status="spell"
        echo "Spell Check is turned on."
    endif
    exe "setlocal " . spl_status
endfunc
nnoremap <silent><F4> :call ToggleSpellCheck()<CR>


"""""""""""""
" Filetypes "
"""""""""""""

au FileType gitcommit,tex,markdown set spell

au FileType make set noexpandtab " need hard tab for Makefile

au FileType yaml set noautoindent
