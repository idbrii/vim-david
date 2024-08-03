
" Mundo -- visualize the undo tree (a fork of gundo).
if !exists("g:loaded_mundo") || !g:loaded_mundo
    finish
endif

nnoremap <F2> :<C-u>MundoToggle<CR>

" Remove deprecated commands (they're replaced with Mundo commands).
delcommand GundoToggle
delcommand GundoShow
delcommand GundoHide
delcommand GundoRenderGraph
