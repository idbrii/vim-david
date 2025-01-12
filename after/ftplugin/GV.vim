" I use gq to quit instead.
nunmap <buffer> q

" I added refresh to gv.
nmap <silent> <buffer> <C-l>     <Plug>(gv-refresh)<Plug>(david-redraw-screen)

" Expand commit like in a fugitive-gitcommit buffer.
" nowait because of vim-sideways.
nmap <nowait><silent> <buffer> > <CR>

" Yank commit sha.
if has('mac') || !has('unix') || has('xterm_clipboard')
    nnoremap <silent> <buffer> yc :<C-u>let @+ = gv#sha()<CR>
else
    nnoremap <silent> <buffer> yc :<C-u>let @" = gv#sha()<CR>
endif

" Cycle between refs.
function! s:search_for_head(direction, count)
    let search_bak = @/

    " Regex: Graph dots, date, sha, ref/msg.
    let @/ = '\v^[* /|]*[0-9-]{10}\s\x{7,40} \(<'
    let dir = (a:direction ? "/" : "?")
    let search = a:count .. (a:direction ? "n" : "N")
    exec 'silent normal! '.. search
    nohl

    let @/ = search_bak
endf
nnoremap <silent> <buffer> r :<C-u>silent call <SID>search_for_head(1, v:count)<CR>
nnoremap <silent> <buffer> R :<C-u>silent call <SID>search_for_head(0, v:count)<CR>


" Open commit in preview window like other fugitive buffers.
nnoremap <buffer> p <Cmd>pclose<Bar>split<Bar>exec "Gedit" gv#sha()<Bar>pedit<Bar>close<CR>
