" log files
"
au BufRead,BufNewFile *.log setfiletype log

" Text files as logs. Can't use setfiletype because vim's filetype.vim sets *.txt to text.
" Name contains log:
au BufRead,BufNewFile *\Alog\A*.txt,*_log.txt set filetype=log
