" Supplementary git settings
" (So don't use did_ftplugin -- the base setting is already done and we just
" want to put some icing on it.)

if !exists('g:loaded_fugitive')
    finish
endif

" Diffs are harder to read when they wrap and it's rarely useful.
setlocal nowrap

if david#git#is_buf_from_fugitive_cmd(bufnr(''), "branch")

    function! s:LogBranch()
        let br = expand("<cWORD>")
        if empty(br) || br !~ '\w'
            return
        endif

        let cmd = printf("GV --no-merges %s ^%s", br, FugitiveHead())
        return execute(cmd)
    endfunction

    nnoremap <buffer> <C-CR> <cmd>call <SID>LogBranch()<CR>

endif
