
command! -buffer -range Gpeekcommit call david#git#peek_line()

augroup david_fugitive
    au! * <buffer>
    " o opens the commit in a split, but I often just want to see the commit
    " message. Use a popup window.
    " Consider only invoking if cursor is in first column?
    autocmd CursorHold <buffer> Gpeekcommit
augroup END

" Provide mapping to avoid repeated waiting. This uses x for examine.
nnoremap <buffer> x :<C-u>Gpeekcommit<CR>
" Blame's not useful inside blame, so peek instead.
nnoremap <buffer> <Leader>gb <Cmd>Gpeekcommit<CR>
xnoremap <buffer> <Leader>gb <Cmd>Gpeekcommit<CR>
" Fugitive reblame at commit with Glineblame mapping (which I think of as
" "jump to blame").
nmap <buffer> <Leader>gB -
xmap <buffer> <Leader>gB -

" File diff that changed current line. Needs remap to use fugitive's CR.
nmap <buffer> dd <CR>?^diff<CR><CR>
