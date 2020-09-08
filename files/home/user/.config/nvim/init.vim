" ---- GLOBAL SETTINGS ----

" 1 tab is 4 spaces, with intelligent indenting
set shiftwidth=4
set tabstop=4
set expandtab
set cinkeys-=:

" Sets how many lines of history VIM has to remember
set history=500

" Don't fold anything
set nofoldenable

" Complete mouse support
set mouse=a

" The vertical hint delimiter
set colorcolumn=79

" Shows the line count on the left
set relativenumber
set invnumber

" System clipboard by default and not clearing it when vim is closed
set clipboard=unnamedplus
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Windows won't resize when opening/closing files
set noequalalways

" Enables italics
highlight Comment cterm=italic gui=italic


" ---- COMMANDS ----

command QuickHelp :silent !firefox "https://github.com/marioortizmanero/dotfiles/blob/master/cheatsheets/VIM.md"
command CopyDir :let @+ = expand("%:p:h")
command CloneDir :silent exec "!alacritty --working-directory" expand('%:p:h') "-e sh -c 'ls; $SHELL' &"
command Term :belowright 13split | terminal


" ---- BINDINGS ----

" Leader key for custom commands
let mapleader = ","

" Disable search highlighting when escape is pressed
nnoremap <silent><esc> :noh<CR>

" Open current location in new window with ls
nnoremap <leader>+ :CloneDir<CR>

" Quick custom terminal command
noremap <leader>t :Term<CR>

" Exit terminal insert mode with Esc
tnoremap <Esc> <C-\><C-n>

" Indentation type toggle
noremap <leader>i :call TabToggle()<CR>
function! g:TabToggle()
  if &expandtab
    set shiftwidth=4
    set softtabstop=0
    set noexpandtab
  else
    set shiftwidth=4
    set softtabstop=4
    set expandtab
  endif
endfunction

" Toggle for the line numbers to the left
noremap <leader>n :set relativenumber!<CR>

" Toggle to show the colorcolumn at 120 characters or 79
noremap <leader>l :call ColumnToggle()<CR>
function! g:ColumnToggle()
    if &colorcolumn != 120
        set colorcolumn=120
    else
        set colorcolumn=79
    endif
endfunction

" Fuzzy finder shortcuts
noremap <leader>ff :Files<CR>
noremap <leader>fl :Lines<CR>


" ---- PLUGINS ----

call plug#begin('~/.vim/plugged')
    " LSP configuration
    Plug 'neovim/nvim-lsp'
    Plug 'haorenW1025/completion-nvim'
    Plug 'haorenW1025/diagnostic-nvim'
    " Theme
    Plug 'joshdick/onedark.vim'
    " Status bar
    Plug 'itchyny/lightline.vim'
    " Efficient colorizer
    Plug 'norcalli/nvim-colorizer.lua'
    " Toml syntax highlighting
    Plug 'cespare/vim-toml'
    " Git diff symbols to the left
    Plug 'airblade/vim-gitgutter'
    " Git wrapper
    Plug 'tpope/vim-fugitive'
    " Comment and uncomment easily
    Plug 'scrooloose/nerdcommenter'
    " File manager
    Plug 'scrooloose/nerdtree'
    " Fuzzy finder
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    " LaTeX editing
    Plug 'lervag/vimtex'
    " Live markdown preview
    Plug 'PratikBhusal/vim-grip'
call plug#end()


" NERDCommenter
let g:NERDSpaceDelims = 1
let g:NERDCreateDefaultMappings = 0
let g:NERDCustomDelimiters = { 'c': { 'left': '//'} }
let g:NERDDefaultAlign = 'left'
noremap <leader>c :call NERDComment(0,'Toggle')<CR>


" Lightline
set noshowmode
set laststatus=2


" GitGutter
set updatetime=300


" NERDTree
" Open at start if vim was launched without parameters
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter *
    \ if (argc() == 0 && !exists("s:std_in")) || isdirectory(expand('%'))
        \ | NERDTree |
    \ endif
let g:NERDTreeShowHidden=1
let g:NERDTreeWinSize=20
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''


" Fuzzy finder
let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit' }


" Neovim LSP
lua << EOF
    -- Customization of the servers
    local nvim_lsp = require'nvim_lsp'

    -- Function to initialize the LSP config after the buffer is attached
    local on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        require'completion'.on_attach()
        require'diagnostic'.on_attach()
  
        -- Mappings, only loaded when necessary.
        local opts = { noremap=true, silent=true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)
    end

    local servers = {'cssls', 'html', 'pyls', 'ccls', 'bashls', 'rust_analyzer'};
    local configs = { };
    for _, lsp in ipairs(servers) do
        -- The default arguments are merged with the custom ones.
        local args = { on_attach = on_attach }
        if configs[lsp] then
            for key, val in pairs(configs[lsp]) do
                args[key] = val
            end
        end

        nvim_lsp[lsp].setup(args)
    end
EOF

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" Tab to show the auto-completion pop-up. Also, use <Tab> and <S-Tab> to
" navigate through popup menu.
let g:completion_enable_auto_popup = 0
function! s:smart_tab_complete()
    " If the completion window is already visible, iterate the results
    " starting from the beginning.
    if pumvisible()
        return "\<C-N>"
    endif

    " Current line
    let line = getline('.')

    " From the start of the current line to one character right of the cursor
    let substr = strpart(line, -1, col('.')+1)

    " Word till cursor nothing to match on empty string
    let substr = matchstr(substr, "[^ \t]*$")
    if (strlen(substr)==0)
        return "\<tab>"
    endif

    if (match(substr, '\/') != -1)
        " File matching
        return "\<C-X>\<C-F>"
    elseif (match(substr, '\.') != -1)
        " Plugin matching
        return "\<C-X>\<C-O>"
    else
        if luaeval('#vim.lsp.buf_get_clients() ~= 0')
            " Using the LSP
            return completion#trigger_completion()
        else
            " Existing text matching
            return "\<C-X>\<C-P>"
        endif
    endif
endfunction

inoremap <silent><expr> <tab> <SID>smart_tab_complete()
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


" Theme
set termguicolors
let g:onedark_terminal_italics = 1
" Background color is the terminal's
augroup colorset
    autocmd!
    let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
    autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white })
    augroup END
augroup END
" Comments have more constrast
let g:onedark_color_overrides = {
  \ "comment_grey": { "gui": "#757c8a", "cterm": "59", "cterm16": "15" },
  \ }
" Setting the theme at the end
colorscheme onedark
" Lightline theme, too
let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }


" Neovim colorizer set-up
lua require'colorizer'.setup()


" Vimtex
let g:vimtex_view_general_viewer = 'zathura'
let g:tex_flavor = 'latex'
