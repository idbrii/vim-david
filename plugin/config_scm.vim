" Source Control

set diffopt+=vertical
if has("patch-8.1.0360")
    set diffopt+=internal,algorithm:patience,indent-heuristic
endif

" Mergetool          {{{1

" Remote vs Merged since merged contains changes on top of what's in remote.
let g:mergetool_layout = 'rm'

" I want equal sized windows.
function s:on_mergetool_set_layout(split)
    " Relayout windows too.
    wincmd =
    " Ensure filetypes are set.
    if empty(&filetype) && !empty(a:split.filetype)
        execute 'setfiletype' a:split.filetype
    endif
endfunction
let g:MergetoolSetLayoutCallback = function('s:on_mergetool_set_layout')

" Git          {{{1
if executable('git')

    augroup david_git
        au!
        autocmd User FugitiveIndex call david#fugitive#ConfigureIndexBuffer()
    augroup END

    " I almost always do verbose, so define my own Gcommit that uses full
    " vertical height. See vim-fugitive#1519.
    command! -bang -nargs=? -range=-1 -complete=customlist,fugitive#CommitComplete Gcommit call david#git#GitCommit(<line1>, <count>, +"<range>", <bang>0, "<mods>", "commit " .. <q-args>)

    " Fugitive
    nnoremap <Leader>gi :Git<CR>gg)
    nnoremap <Leader>gd :Gdiffsplit<CR>
    nnoremap <Leader>gD :Gdiffsplit HEAD<CR>

    " GV
    " V: visual repo history
    nnoremap <leader>gV :GV -n 1000 --all<CR>
    " v: visual file history
    nnoremap <leader>gv :GV! -n 100<CR>
    xnoremap <leader>gv :GV! -n 100<CR>

    command! -bar -range=% -nargs=? Gblame :silent! cd %:p:h | call david#git#Gblame('<line1>,<line2>', <q-args>)
    nnoremap <Leader>gb :Gblame -w<CR>

    command! -range Gpopupblame <line1>,<line2>call david#git#Gblame_popup()
    command! -range Glineblame  <line1>,<line2>call david#git#Gblame_showline()
    xnoremap <Leader>gb :Gpopupblame<CR>
    xnoremap <Leader>gB :Glineblame<CR>

    command! -nargs=* Ghistory GV! --all <args>
    " Show stashes in quickfix. An interactive :Git stash list (cz? lists maps)
    command! Gstashlist Gclog -g stash

    " Implement my own fugitive_legacy_commands without the deprecation
    " warnings.
    command! -bar -bang -nargs=0 Gremove exe fugitive#RemoveCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])
    command! -bar -bang -nargs=0 Gdelete exe fugitive#DeleteCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])
    command! -bar -bang -nargs=1 -complete=customlist,fugitive#CompleteObject Gmove   exe fugitive#MoveCommand(  <line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])
    command! -bar -bang -nargs=1 -complete=customlist,fugitive#RenameComplete Grename exe fugitive#RenameCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])
    command! -bar -bang -range=-1 -nargs=* -complete=customlist,fugitive#CompleteObject Gbrowse exe fugitive#BrowseCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>, [<f-args>])


    command! -nargs=1 Grevert call david#git#GitRevert(<f-args>)

    " Delete Fugitive buffers when I leave them so they don't pollute BufExplorer
    augroup FugitiveCustom
        autocmd BufReadPost fugitive://* set bufhidden=delete
    augroup END
endif

" Perforce          {{{1
let no_perforce_maps = 1
let g:p4CheckOutDefault = 1		" Yes as default
let g:p4MaxLinesInDialog = 0	" 0 = Don't show the dialog, but do I want that?

" VC          {{{1
" The defaults are random and disorganized. Instead, let's put them all under
" one initial leader - f. (The same that perforce uses, but I don't use vc
" with perforce.)
let g:vc_allow_leader_mappings = 0
" Randomly maps a common key globally for grep.
let g:no_vc_maps = 1

" Currently, I only use vc for svn.
if executable('svn')
    " I like to do extra formatting.
    let g:vc_commit_allow_blank_lines = 1

    " I keep thinking this is a "Press Enter to continue" prompt.
    let g:vc_donot_confirm_cmd = 1

    " Sometimes VCDiff doesn't work. Give me a backup.
    command! -nargs=? SvnDiff :silent call david#svn#SvnDiff(expand("%"), <q-args>)
    command! -count=0 SvnDay call david#svn#SvnDay(<count>)

    " Easy copy message from svn when committing to git. Uses the file under
    " cursor (from a git commit message buffer).
    command! SvnLastMessage call david#svn#SvnLastMessage()
    command! GcommitSvnMsg :Gcommit -v | call search('to be committed:\n.*:\s*\w', 'e') | SvnLastMessage
    command! -nargs=1 Gittrunkswitch :Git switch trunk | G ff <args>
    command! -nargs=1 Gitmainswitch :Git switch main | G ff <args>
    command! -nargs=1 Gitnextswitch :Git switch next | G ff <args>

    " There's no VCShow like git show.
    command! -nargs=+ SvnShow call david#svn#show(<q-args>)

    " VCMove often fails. Requires relative or repo paths, but even then it
    " thinks I'm moving to the filesystem. This is probably not as safe, but
    " works.
    command! -nargs=1 -complete=file MoveSvn :call david#svn#SvnMove(expand("%:p"), <q-args>)
    command! -nargs=1 -complete=file MoveUnity :call david#svn#SvnMoveUnity(expand("%:p"), <q-args>)

    " For some reason VCDiff takes ~5 seconds to do a diff, but !svn diff
    " and cat are instant. This one takes about 2 seconds.
    " We're loaded before vc, so we can't clobber VCDiff
    command! VCDiffFast call david#svn#VCDiffFast('HEAD')

    command! -nargs=? VCUpdate call david#svn#VCUpdate(<f-args>)

    " Ensure the blame window will have a path inside the repo.
    nnoremap <silent> <leader>fb :silent! cd %:p:h <Bar>silent VCBlame<CR>
    " Diff against have revision.
    nnoremap <silent> <leader>fd :Sdiff<CR>
    " Diff against head revision.
    nnoremap <silent> <leader>fD :Sdiff % HEAD<CR>
    nnoremap <silent> <leader>fi :Sstatus<CR>
    nnoremap <silent> <leader>fIu :VCStatus -u<CR>
    nnoremap <silent> <leader>fIq :VCStatus -qu<CR>
    nnoremap <silent> <leader>fIc :VCStatus .<CR>
    nnoremap <silent> <leader>fV :exec 'Sclog! '. g:david_project_root<CR>
    nnoremap <silent> <leader>fv :Sclog<CR>
    " Explore
    nnoremap <silent> <leader>fe :VCBrowse<CR>
    nnoremap <silent> <leader>fEm :VCBrowse<CR>
    nnoremap <silent> <leader>fEw :VCBrowseWorkingCopy<CR>
    nnoremap <silent> <leader>fEr :VCBrowseRepo<CR>
    nnoremap <silent> <leader>fEl :VCBrowseMyList<CR>
    nnoremap <silent> <leader>fEb :VCBrowseBookMarks<CR>
    nnoremap <silent> <leader>fEf :VCBrowseBuffer<CR>
    nnoremap <silent> <leader>fq :diffoff! <CR> :q<CR>
    nnoremap <silent> <leader>f* :<C-u>call vc#grep#do("*".fnamemodify(expand('%'), ':e'), expand("<cword>")) <CR>
    vnoremap <silent> <leader>f* :<C-u>call vc#grep#do("*".fnamemodify(expand('%'), ':e'), expand("<cword>")) <CR>
endif


if executable('TortoiseProc')
    " A visual version of VC commands (with less capitalization please).
    " Reference: https://tortoisesvn.net/docs/release/TortoiseSVN_en/tsvn-automation.html
    command! -nargs=+ Vcv        call david#svn#TortoiseCommand(<f-args>)
    command! -nargs=? Vcvlog     call david#svn#TortoiseCommand('log', <q-args>)
    command! -nargs=? Vcvblame   call david#svn#TortoiseCommand('blame', <q-args>)
    command! -nargs=? Vcvdiff    call david#svn#TortoiseCommand('diff', <q-args>)
    command! -nargs=? Vcvswitch  call david#svn#TortoiseCommandOnInputPathOrRoot('switch', <q-args>)
    command! -nargs=? Vcvrepo    call david#svn#TortoiseCommandOnInputPathOrRoot('repobrowser', <q-args>)
    command! -nargs=? Vcvrepolog call david#svn#TortoiseCommandOnInputPathOrRoot('log', <q-args>)
    command! -nargs=? Vcvstatus  call david#svn#TortoiseCommandOnInputPathOrRoot('repostatus', <q-args>)
endif

"}}}
" vi: et sw=4 ts=4 fdm=marker fmr={{{,}}}
