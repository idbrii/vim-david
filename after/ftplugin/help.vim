" For some reason in Ubuntu 10.10, keywordprg is always set to man
" Vim should use help
setlocal keywordprg=:help


if &buftype != 'help' && &modifiable
    " When it's an editable file, the buftype changes to empty.
    " nvim right aligns tags with their last char in 76th column.
    setlocal colorcolumn=77
endif

" Easy echo. Copied from vim ft.
nnoremap <buffer> <Leader>ve 0"cy$:echo <C-r>c<CR>
" Silent so remap isn't visible.
xnoremap <buffer><silent> <Leader>ve "cy:execute 'echo '. @c<CR>

