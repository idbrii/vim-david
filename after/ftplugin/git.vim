" Supplementary git settings
" (So don't use did_ftplugin -- the base setting is already done and we just
" want to put some icing on it.)

if !exists('g:loaded_fugitive')
    finish
endif

function! s:LogBranch()
    let br = expand("<cWORD>")
    if empty(br) || br !~ '\w'
        return
    endif
    
    let cmd = printf("GV --no-merges %s ^%s", br, FugitiveHead())
    return execute(cmd)
endfunction

nnoremap <buffer> <C-CR> <cmd>call <SID>LogBranch()<CR>
