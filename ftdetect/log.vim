" log files
"
au BufRead,BufNewFile *.log setfiletype log
" Can't use setfiletype because vim's filetype.vim sets *.txt to text.
au BufRead,BufNewFile *\Alog\A*.txt set filetype=log
