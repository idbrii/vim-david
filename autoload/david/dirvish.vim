
function! david#dirvish#OnShdoCreated() abort
    " Using autochdir requires a preamble or scripts execute from tmp.
    if has('win32')
        " work across hard drives
        let chdir = 'pushd '
    else
        let chdir = 'cd '
    endif
    call append(0, [chdir .. b:dirvish_dir, ''])
endf
