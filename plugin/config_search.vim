" Allow commands like :find to search recursively from the current file's
" directory. Ideally, I should set path to some useful directories, but I
" don't have a good working set right now.
set path+=./**

" Magic global search (see smagic)
nnoremap gs :%sm/
xnoremap gs :sm/
nnoremap gS :%S/
xnoremap gS :S/

" Default * to match case since I usually want exact matches. Can just remove
" \C from end of query to disable.
let g:searchsavvy_always_case_sensitive_star = 1

" Refactor remap.
" Go to local definition and replace it in local scope. Uses textobj-indent
" (for ai map).
nmap gr 1gdvaio:s/<C-R>/\C//gc<left><left><left>
" Similar map for selections to turn an expression into a variable. No point
" of definition so just use indent from textobj-indent. Clobbers @c register.
xmap gr "cyvaio:s/<C-R>c\C//gc<left><left><left>

" <C-l> redraws the screen and removes any search highlighting. Define and use
" a Plug so I can use the same Plug in maps for other plugins.
" For general case (not other plugins, also regenerate folds).
nnoremap <silent> <Plug>(david-redraw-screen) :<C-u>nohl<CR><C-l>
nmap <silent> <C-l> <Plug>(FastFoldUpdate)<Plug>(david-redraw-screen)

" Quick fix slashes
"	win -> unix
xnoremap <A-/> :s/\\/\//g<CR>:nohl<CR>
if has('mac')
    " A-/ isn't mappable on mac.
    xnoremap <D-/> :s/\\/\//g<CR>:nohl<CR>
endif
"	unix -> win
xnoremap <A-?> :s/\//\\/g<CR>:nohl<CR>

" Todo: uses prefix <Leader>t
" Quickly find todo items
nnoremap <Leader>tt :vimgrep "\C\v(TODO<Bar>HACK)" %<CR>

" Open-ended todo
nnoremap <Leader>tT :grep -e TODO -e HACK -R .
" Project-wide todos
" Using character classes to avoid quote or Bar which aren't playing nice with
" AsyncRun.
nnoremap <Leader>tp <Cmd>exec 'NotGrep [TH][OA][DC][OK].'. g:snips_author<CR>
nnoremap <Leader>tP <Cmd>exec 'NotGrep [TH][OA][DC][OK][:(]'<CR>
nnoremap <Leader>tl :Todo<CR>

" Filters the quickfix list to keep results matching pattern. Bang removes
" remove results matching the pattern. `:QFilter file|folder` and the list
" will be filtered to that.
" Source: http://www.reddit.com/r/vim/comments/1t39xl/filtering_quickfix_list/
function! s:FilterQuickfixList(bang, pattern)
  let cmp = a:bang ? '!~#' : '=~#'
  call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) " . cmp . " a:pattern"))
endfunction
command! -bang -nargs=1 -complete=file QFilter call s:FilterQuickfixList(<bang>0, <q-args>)


" vi: et sw=4 ts=4 fdm=marker fmr={{{,}}}
