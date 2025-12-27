" See also ../after/ftplugin/gdscript.vim

" godot lsp sends massive lists of results and asyncomplete hangs on them.
" However, lsp omnicompletion doesn't seem to work at all. Works with
" reprovimrc, so this needs debugging.
"~ let b:asyncomplete_enable = 0
let b:asyncomplete_min_chars = 5


" Godot creates .uid files for every script which makes it difficult to
" navigat with Dirvish. Ignore them to hide.
set wildignore+=*.uid

if g:zfdirdiff_FileExclude !~# "import"
    " Ignore godot import files in diffs because usually I'm looking for code.
    let g:zfdirdiff_FileExclude .= ",*.import"
endif

