function! david#profiler#Start(log_name) abort
    let path = a:log_name
    if empty(path)
        let path = 'profile.log'
    endif
    if path !~ '\.'
        let path .= ".log"
    endif
    
    let path = expand('~/.vim-cache/temp/') .. path

    exec 'profile start' path
    profile func *
    profile file *
    echomsg printf("Logging profile to ".. path)
    command! ProfilerFinish call david#profiler#Finish()
endf

function! david#profiler#Finish() abort
    profile pause
    noautocmd qall!
endf
