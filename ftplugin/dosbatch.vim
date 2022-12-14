" Make it easy to jump to files defined in batch files
setlocal isfname-==

" Run batch files and capture their output in quickfix
" Need to be fancy for files with spaces.
let &l:makeprg = '"'.. expand("%:p") ..'"'

" Built-in dosbatch syntax file provides no folding
if &foldmethod != 'diff'
    setlocal foldmethod=indent
endif

" :: Is how I insert documentation comments, but commentstring is generally
" for inserting temporary commments.
setlocal commentstring=REM\ %s
