
function! david#git#peek_commit(sha) abort
    let text = systemlist("git -C ".. shellescape(FugitiveCommonDir()) .." log -n1 ".. a:sha)
    let opts = { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 }
    call setbufvar(winbufnr(david#window#popup_atcursor(text, opts)), "&filetype", "git")
endf

function! david#git#peek_line() abort
    let tokens = getline('.')->split()
    if empty(tokens)
        return
    endif
    
    let sha = tokens[0]
    if str2nr(sha, 16) > 10000
        return david#git#peek_commit(sha)
    endif
endf


function! david#git#GitCommit(line1, line2, range, bang, mods, args) abort
    let bufnr = bufnr()
    exec fugitive#Command(a:line1, a:line2, a:range, a:bang, a:mods, a:args)
    if bufnr != bufnr()
        wincmd _
    endif
endf

function! david#git#Gblame(range, args)
    " :Gblame scrollbinds the blame window but doesn't support time travel.
    " Instead, use :%Gblame which uses a disconnected blame window and
    " supports C-i/o to travel through time (even across reblames).
    let winview = winsaveview()
    exec a:range ..'Git blame '.. a:args
    wincmd T
    setlocal nowrap
    call winrestview(winview)
    " Offset to the right past the commit info column.
    normal! 64l
endf

function! s:get_blame_for_line() abort range
    return systemlist("git -C ".. shellescape(expand('%:p:h')) ..printf(" log --ignore-space-at-eol --ignore-space-change --no-merges -n 1 -L %i,%i:", a:firstline, a:lastline)  .. shellescape(resolve(expand("%:t"))))
endf

function! david#git#Gblame_showline() abort range
    let info = s:get_blame_for_line()
    let commit = info[0]->split()[1]
    exec 'Gedit '.. commit
endf

function! david#git#Gblame_popup() abort range
    let opts = { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 }
    let popup = david#window#popup_atcursor(s:get_blame_for_line(), opts)
    call setbufvar(winbufnr(popup), "&filetype", "git")
endf

function! david#git#GitRevert(commit)
    try
        exec 'Git revert --no-commit '. a:commit
        if v:shell_error <= 1
            " No problems means we can go straight to commit.
            " On Windows
            Git commit -v
            return
        endif
    catch /^fugitive:/
        " TODO: How to get fugitive hint to draw?
        " It shows in terminal, so should be okay.
        echo v:exception
    endtry
    " How to open status regardless of fugitive errors?
    Git
endf


function! david#git#is_buf_from_fugitive_cmd(bufnr, cmd) abort
    return 0 == get(FugitiveResult(a:bufnr), 'args', [])->index(a:cmd)
endf
