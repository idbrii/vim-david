" Wrapper around obsession to use my common session path.

function! s:IsObsession() abort
    return !empty(get(g:, 'this_obsession', ''))
endf

function! david#session#GetSessionInfo() abort
    let session_type = s:IsObsession() ? 'Obsession' : 'Session'
    return printf('Current %s: %s', session_type, v:this_session)
endf

function! s:name_to_session_file(name) abort
    let name = a:name
    if empty(name)
        let name = "standard"
    endif
    if name =~ '[./\\]'
        echoerr "Pass a name, not a filename."
        throw v:errmsg
    endif
    return david#path#to_unix(printf("~/.vim-cache/session/%s.vim", name))
endf

function! david#session#StartObsession(name) abort
    let file = s:name_to_session_file(a:name)
    
    call mkdir(fnamemodify(file, ":p:h"), 'p', 0o700)
    if filereadable(file)
        " If already exists, load it. This will setup obsession if it was an
        " obsession session, but we'll run obsession just in case.
        exec 'source' file
    endif
    exec 'Obsession' file
    call setfperm(file, 'rw-------')
    " Don't need to echo. Obsession will do it for us.
    " echo david#session#GetSessionInfo()
endf

" Like StartObsession, but only for existing sessions and may not setup
" obsession. Probably not that useful.
function! david#session#LoadSession(name) abort
    let file = s:name_to_session_file(a:name)
    exec 'source' file
    echo david#session#GetSessionInfo()
endf
