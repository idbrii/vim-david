function! david#svn#create_resolve_file()
    " Get the merge details
    exec "normal! gg0I:: \<Esc>j."
    0,2delete c

    " Only care about conflict files
    %v/\v^(tree )?conflict/d
    %sm/^Tree conflict: /@call :resolvetree /e
    %sm/^Conflicted: /@call :resolvefile /e
    %sort
    0put c
    normal! Go
    let subroutines = [''
                \ , '@goto:eof'
                \ , ''
                \ , ':resolvefile'
                \ , 'svn resolve --accept theirs-full %*'
                \ , '@goto:eof'
                \ , ''
                \ , ':resolvetree'
                \ , 'svn resolve --accept theirs-full %*'
                \ , '@REM svn wants to do this but that loses incoming data:'
                \ , '@REM svn resolve --accept working %*'
                \ , '@REM This answer says something crazy:'
                \ , '@REM https://stackoverflow.com/a/11016568/79125'
                \ , '@REM Ugh.'
                \ , '@goto:eof'
                \ ]
    call append('$', subroutines)
    update
    " highlight binary files
    let @/ = '\vzip|fla|png|exe'
    silent normal! n
endf


" Confirm revert before proceeding.
function! david#svn#ConfirmRevert(...)
    let files = join(a:000, ' ')
    if len(files) == 0
        let files = expand('%')
    endif
    if confirm("Revert?\n". files, "&Yes\n&No") == 1
        call call('vc#Revert', a:000)
    endif
endf

function! david#svn#get_branch()
    if !exists("*systemlist")
        " Could implement it ourself...
        return ""
    endif

    if exists("b:svndavid_branch")
        return b:svndavid_branch
    endif

    " airline needs us to track our svn directory for some reason.
    let b:svn_dir = finddir(".svn", '.;/') " somewhere above us

    " Always define it so we don't keep retrying. Clear it when we leave the
    " buffer so it's somewhat up to date.
    let b:svndavid_branch = ""
    " Use a buffer-unique group name to prevent clearing autocmds for other
    " buffers.
    exec 'augroup svndavid-'. bufnr("%")
        au!
        autocmd BufWinLeave <buffer> unlet! b:svndavid_branch
    augroup END

    let shellslash_bak = &shellslash
    let &shellslash = 0
    " Based on: https://stackoverflow.com/a/39516489/79125
    let svninfo = systemlist("svn info ". shellescape(expand("%:p:h")))
    let &shellslash = shellslash_bak

    for line in svninfo
        let branch = matchstr(line, '\v^URL:.*\zs((tags|branches)/[^/]+|trunk)', 0, 1)
        let branch = substitute(branch, '\v^[^/]+/', '', '')
        if len(branch) > 0
            let b:svndavid_branch = branch
            return branch
        endif
    endfor
    return ""
endf

" Sometimes VCDiff doesn't work. Give me a backup.
function! david#svn#SvnDiff(fname, optional_revision)
    silent Scratch diff
    let revision = a:optional_revision
    if len(revision) > 0 && revision[0] != '-'
        let revision = '-r '. revision
    endif
    exec '.! svn diff '. a:fname .' '. revision
    if has('mac')
        %sm/\r$//
    endif
endf
command! -nargs=? SvnDiff :silent call david#svn#SvnDiff(expand("%"), <q-args>)

function! s:SvnUser()
    let auth = systemlist("svn auth")
    for entry in auth
        if entry =~# '^Username:'
            return split(entry)[1]
        endif
    endfor
    return ''
endf
function! s:SvnRepoUrl()
    return split(systemlist("svn info ".. g:david_project_root)[2])[1]
endf
function! s:SvnRelativeDate(seconds_from_now)
    " Date relative to today
    let today = localtime()
    return strftime("{%Y-%m-%d}", today + a:seconds_from_now)
endf

function! david#svn#SvnDay(days_ago)
    " Show log of changes made by local user today.
    " Should I put this into sovereign?
    let days = 24*60*60
    " Use today and tomorrow. svn will search based on start of day. See
    " https://stackoverflow.com/a/15759896/79125
    let search = ''
    let user = s:SvnUser()
    if !empty(user)
        let search = '--search '.. user
    endif
    let cmd = printf("svn log --revision %s:%s %s %s", s:SvnRelativeDate(-a:days_ago * days), s:SvnRelativeDate((1 - a:days_ago)*days), search, s:SvnRepoUrl())
    let log = systemlist(cmd)
    let log = map(log, { i, val -> trim(val) })
    silent Scratch svnlog
    silent call append(0,log)
    silent 0put =cmd
    " Snap to width used
    vertical resize 81
endf
command! -count=0 SvnDay call david#svn#SvnDay(<count>)

" Easy copy message from svn when committing to git. Uses the file under
" cursor (from a git commit message buffer).
function! david#svn#SvnLastMessage() abort
    let fname = expand('<cfile>')
    if !empty(fname)
        " Assuming we're in a COMMIT_EDITMSG from .git
        let fname = printf('%s/../%s', expand('%:h'), fname)
    endif
    if !filereadable(fname)
        " Wasn't on a file, try last buffer.
        let fname = expand('#')
    endif

    " incremental omits a trailing line
    let log = systemlist("svn log --limit 1 --incremental ".. fname)
    if v:shell_error
        silent 0put =v:shell_error
    endif

    let log = map(log, { k,v -> trim(v) })
    call add(log, "\n") " not all commits have trailing newline
    silent 0put =log[:2]
    silent 0put =log[3:]
    norm! gg
endf
command! SvnLastMessage call david#svn#SvnLastMessage()
command! GcommitSvnMsg :Gcommit -v | call search('to be committed:\n.*:\s*\w', 'e') | SvnLastMessage

" There's no VCShow like git show.
command! -nargs=+ SvnShow :Sedit <args>

" VCMove often fails. Requires relative or repo paths, but even then it
" thinks I'm moving to the filesystem. This is probably not as safe, but
" works.
function! david#svn#SvnMove(src, dest) abort
    let shellslash_bak = &shellslash
    let &shellslash = 0

    let src = shellescape(a:src)
    let output = system('svn mv '. src .' '. shellescape(a:dest))
    if v:shell_error
        echo output
    else
        exec 'keepalt edit '. a:dest
    endif

    let &shellslash = shellslash_bak
    return !v:shell_error
endf
command! -nargs=1 -complete=file MoveSvn :call david#svn#SvnMove(expand("%:p"), <q-args>)
function! david#svn#SvnMoveUnity(src, dest) abort
    let success = david#svn#SvnMove(a:src .'.meta', a:dest .'.meta')
    if success
        call david#svn#SvnMove(a:src, a:dest)
    else
        echo 'Try MoveSvn instead.'
    endif
endf
command! -nargs=1 -complete=file MoveUnity :call david#svn#SvnMoveUnity(expand("%:p"), <q-args>)

function! david#svn#VCDiffWithDiffusable(diff_latest)
    "" Make VCDiff auto-disable diff mode when one window is closed.

    " Ensure the diff window will have a path inside the repo.
    silent! cd %:p:h
    if a:diff_latest
        " 'Forces diff to start with the revision from the trunk/branch for subversion.'
        " Seems to mean diff latest instead of diff have revision.
        silent VCDiff!
    else
        " Seems to diff against have revision.
        silent VCDiff
    endif
    if has('mac')
        %sm/\r$//
    endif
    " My hack to vim-vc calls diffusable for me.
    "call diffusable#diff_with_partner(winnr('#'))
    wincmd p
    "call diffusable#diff_with_partner(winnr('#'))
endf

" For some reason VCDiff takes ~5 seconds to do a diff, but !svn diff
" and cat are instant. This one takes about 2 seconds.
function! david#svn#VCDiffFast(revision) abort
    let lazyredraw_bak = &lazyredraw
    set lazyredraw
    let itchy_bak = g:itchy_split_direction
    let g:itchy_split_direction = 1

    mark c

    " Ensure svn will have a path inside the repo.
    silent! cd %:p:h

    " Get a nice name for the diff file. No noticeable affect on perf.
    let shellslash_bak = &shellslash
    let &shellslash = 0
    let repo_file = shellescape(expand('%:p'))
    let &shellslash = shellslash_bak
    for line in systemlist('svn info '. repo_file)
        if line =~# 'is not a working copy'
            echohl WarningMsg
            echomsg trim(line)
            echohl None
            return

        elseif line =~# '^URL'
            let repo_file = substitute(line, '\vURL: (https?://.{-}.com/)?svn', '', '')
            let repo_file = substitute(repo_file, '%20', ' ', 'g') " url-encoded
            let repo_file = substitute(repo_file, '[%#]', '', 'g') " not allowed
            let repo_file = repo_file[:-2] " remove newline
            break
        endif
    endfor

    let base_file = system('svn cat -r'. a:revision .' '. expand('%'))
    if has('mac')
        " Line endings are messed up on mac, but I'm not sure why. Let's
        " just hide them so my diffs are useable.
        let base_file = substitute(base_file, '\r\n', '\n', 'g')
    endif
    call diffusable#diff_this_against_text(base_file)

    wincmd p
    exec 'silent file '. bufname('%') .'-'. repo_file .'\#'. a:revision
    wincmd p
    " Try to ensure cursor is at the same position. Also close up folds
    " and centre cursor.
    normal! `czMzz

    let g:itchy_split_direction = itchy_bak
    let &lazyredraw = lazyredraw_bak

    " Sometimes when cursor was on unchanged text, base window isn't on
    " the right line and you see no content. Flipping over to it fixes it,
    " but we want to end in local file. I think this must be done while
    " we're redrawing?
    " TODO: Still need to flip around? With the above wincmds?
    "wincmd p
    "wincmd p
endf
" We're loaded before vc, so we can't clobber VCDiff
command! VCDiffFast call david#svn#VCDiffFast('HEAD')

function! david#svn#VCUpdate(...)
    let shellslash_bak = &shellslash
    let &shellslash = 0

    let files = a:000[:]
    if a:0 == 0
        let files = [expand('%')]
    endif

    for i in range(0, len(files)-1)
        let files[i] = shellescape(fnamemodify(files[i], ':p'))
    endfor

    let result = system('svn update '. join(files))
    echo result

    let &shellslash = shellslash_bak
endf


" Tortoise {{{1

function! david#svn#TortoiseCommand(command, optional_path) abort
    let path = a:optional_path
    if len(path) == 0
        let path = '%'
    endif
    let path = david#path#to_unix(path)
    " Ensure svn will have a path inside the repo.
    if isdirectory(path)
        let dir = fnamemodify(path, ':p')
    else
        let dir = fnamemodify(path, ':p:h')
    endif
    exec 'cd' dir
    exec 'AsyncCommand TortoiseProc /command:'. a:command .' /path:"'. path .'"'
endf

function! david#svn#TortoiseCommandOnInputPathOrRoot(command, path) abort
    let path = a:path
    if empty(path)
        let path = g:david_project_root
    endif
    return david#svn#TortoiseCommand(a:command, path)
endfunction
