
" Global entrypoint
function! david#runner#set_entrypoint(args, use_cwd)
    " Use the current file and its directory and jump back there to run
    " (ensures any expected relative paths will work).
    let cur_file = david#path#to_unix('%:p')
    let cur_dir = david#path#to_unix(fnamemodify(cur_file, ':h'))
    if a:use_cwd
        " Using cwd is useful when errors use relative paths.
        let cur_dir = getcwd()
    endif

    if !exists("b:david_original_makeprg")
        let b:david_original_makeprg = &makeprg
    endif

    let entrypoint_makeprg = b:david_original_makeprg
    let entrypoint_makeprg = substitute(entrypoint_makeprg, '%', cur_file, '')
    let entrypoint_makeprg .= ' '.. a:args

    function! DavidProjectBuild() closure
        update
        " May not stop fast enough for run, but you can try again.
        silent AsyncStop
        call execute('lcd '. cur_dir)
        let &makeprg = entrypoint_makeprg
        " Use AsyncRun instead of AsyncMake so we can pass cwd and ensure
        " callstacks are loaded properly.
        call execute('AsyncRun -program=make -auto=make -cwd='. cur_dir .' @')
    endf

    " Don't set ProjectMake so previous proj has a way to build.
    "~ command! ProjectMake call DavidProjectBuild()
    command! ProjectRun  call DavidProjectBuild()
    command! ProjectKill AsyncStop
    let &makeprg = entrypoint_makeprg
endf
