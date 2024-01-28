" Wrapper around obsession to use my common session path.

let s:startup_session = expand("~/.vim-cache/session.vim")

function! s:IsObsession() abort
    return !empty(get(g:, 'this_obsession', ''))
endf

function! david#session#GetSessionInfo() abort
    let session_type = s:IsObsession() ? 'Obsession' : 'Session'
    return printf("%s: '%s' in %s", session_type, get(g:, 'David_current_session', '<none>'), v:this_session)
endf

" This is where I backup sessions to enable switching. s:startup_session is
" the only session used by Obsession. That way we reload our last session.
function! s:name_to_session_file(name) abort
    let name = a:name
    if empty(name)
        throw "Error: Session name is required."
    endif
    if name =~ '[./\\]'
        throw "Error: Pass a name, not a filename:" .. name
    endif
    return david#path#to_unix(printf("~/.vim-cache/session/%s.vim", name))
endf

function! david#session#StartObsession(name) abort
    let expected_perm = 'rw-------'
    if has("win32")
        " Windows only supports user perms (group and others get the same
        " permissions).
        let expected_perm = 'rw-rw-rw-'
    endif

    " We want to restore David_current_session when sessions load.
    set sessionoptions+=globals  " global variables (String and Number) matching /^\u\k*\l\k*/

    if exists("g:David_current_session")
        if a:name == g:David_current_session
            echomsg "Already in session" g:David_current_session
            return
        endif
        " Switching sessions. Save current to appropriate name.
        let old = s:name_to_session_file(g:David_current_session)
        let success = rename(s:startup_session, old)
        echo printf("Saved old '%s' session as %s (%i). Switching to '%s'.", g:David_current_session, old, success, a:name)
    endif

    let g:David_current_session = a:name
    let saved_session = s:name_to_session_file(a:name)

    call mkdir(fnamemodify(saved_session, ":p:h"), 'p', 0o700)
    if filereadable(saved_session) && getfperm(saved_session) != expected_perm
        echo printf("Deleting suspicious session (%s): %s", getfperm(saved_session), saved_session)
        call delete(saved_session)
    end
    if filereadable(saved_session) && expand(v:this_session) != expand(saved_session) && getfperm(saved_session) == expected_perm
        " If exists and not loaded, then load it. This sets up obsession if it
        " was an obsession session, but we'll run Obsession again just in case.
        exec 'source' saved_session
    endif

    " Obsession always operates on our startup session. We only use
    " saved_session for loading.
    exec 'Obsession' s:startup_session
    call setfperm(s:startup_session, expected_perm)
    " Don't need to echo. Obsession will do it for us.
    " echo david#session#GetSessionInfo()
endf


function! david#session#CompleteSessions(ArgLead, CmdLine, CursorPos) abort
    return map(readdir(expand("~/.vim-cache/session")), { k,v -> fnamemodify(v, ":r")})
endf
