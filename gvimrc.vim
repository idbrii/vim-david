" If profiling startup, you'll find applying colorschemes very expensive! We
" shouldn't have applied one in vimrc, so it's okay.
colorscheme sandydune

call david#init#link_highlight_groups() 

if exists("+guitablabel")
    " tab labels show the filename without path(tail)
    set guitablabel=%N/\ %t\ %M
endif


""" Extra menu options
" If we're unix or mac, we probably have the required unix tools
" and ~/.vim is probably our vim folder
if has("unix") || has("mac")
    menu Tools.Build\ David\ Tags   :BuildTags<CR>
endif

if has("mac") && exists("+guifont")
    set guifont=Menlo\ Regular:h13
endif

" =-=-=-=-=-=
" Source local environment additions, if available
runtime glocal.vim
