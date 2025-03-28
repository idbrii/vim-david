if exists('+shellslash')
    function! david#path#to_unix(path)
        let shellslash_bak = &shellslash
        let &shellslash = 1
    
        let p = expand(a:path)
    
        let &shellslash = shellslash_bak
        return p
    endf

else
    function! david#path#to_unix(path)
        return expand(a:path)
    endf
endif

function! david#path#lowercase_drive_letter(path) abort
    let f = a:path
    if f[1] == ':'
        let f = printf('%s:%s', tolower(f[0]), f[2:])
    endif
    return f
endf

function! david#path#normalize(path) abort
    return david#path#lowercase_drive_letter(david#path#to_unix(a:path))
endf

" If relative_parent is a parent of path, return the relative path. Otherwise
" return the absolute path.
function! david#path#relative_to_parent(path, relative_parent) abort
    let file = david#path#normalize(fnamemodify(a:path, ':p'))
    let dir  = david#path#normalize(a:relative_parent)

    if file->stridx(dir) >= 0
        let n = len(dir)
        return file[n+1:]
    endif
    return file
endf

function! david#path#find_upwards_from_current_file(fname)
    " Don't force unix path so vim interprets slashes correctly.
    let current_file_dir = expand('%:p:h')
    if !isdirectory(current_file_dir)
        return ''
    endif
    
    let found = findfile(a:fname, current_file_dir ..';/')
    return found
endf

function! david#path#edit_upwards_from_current_file(fname)
    if stridx(a:fname, '*') >= 0
        echomsg "Glob is not supported"
        return
    endif
    let found = david#path#find_upwards_from_current_file(a:fname)
    if empty(found)
        echomsg printf("Failed to find file '%s' in directory above current file.", a:fname)
    else
        " Using execute() causes ale to fire errors
        "~ call execute('edit '.. found)
        execute 'edit '.. found
    endif
endf

function! david#path#build_kill_from_current_makeprg() abort
    let exe = &makeprg->split()[0]
    if has('win32') && exe !~? ".exe$"
        let exe .= ".exe"
    endif
    if !executable(exe)
        return ''
    endif
    
    let exe = fnamemodify(exe, ':t')
    if has('win32')
        return printf('command! ProjectKill update | call system("taskkill /im %s")', exe)
    else
        return printf('command! ProjectKill update | call system("kill -7 %s")', exe)
    endif
endf

" See also the more aggressive after/plugin/followsymlink.vim
function! david#path#chdir_to_current_file() abort
    call chdir(david#path#get_currentfile_resolved_as_dir())
endf

function! david#path#get_currentfile_resolved_as_dir() abort
    return david#path#normalize(resolve(escape(expand('%:p:h'), '%#')))
endf
function! david#path#get_currentfile_resolved() abort
    return david#path#normalize(resolve(escape(expand('%:p'), '%#')))
endf
function! david#path#get_currentfile_raw() abort
    return david#path#normalize(escape(expand('%:p'), '%#'))
endf
function! david#path#edit_currentfile_resolved() abort
    let file = david#path#get_currentfile_resolved()
    if has('nvim')
        let winview = winsaveview()
        " nvim won't change a file if it's already editing the symbolic link
        " version. BW from vim-bbye.
        " Only wipe if a link since we'll lose marks and other useful bits.
        if file != david#path#get_currentfile_raw()
            BW
        endif
    endif

    execute "edit" file

    if has('nvim')
        call winrestview(winview) 
    endif
endf
