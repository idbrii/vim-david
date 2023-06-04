command! -buffer FormatDocument :exec '%!python3' expand('~/.vim/bundle/aa-david/pythonx/prettyxml.py')
let &l:equalprg = expand('~/.vim/bundle/aa-david/pythonx/prettyxml.py')
