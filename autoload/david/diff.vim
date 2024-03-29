" For vimdiff {{{1

" Only diff the first two args. Does it make sense to diff more?
function! david#diff#close_tabs_containing_args() abort
    " Close existing tabs with these files.
    let arg_bufnrs = map(argv(), { k,v -> bufnr(v) })
    let last_tab = tabpagenr('$')
    " Reverse iteration so tabclose doesn't change index.
    for i in range(last_tab)
        let tab_index = last_tab - i
        let bufs_in_tab = tab_index->tabpagebuflist()
        let contained_args = filter(bufs_in_tab, { k,v -> index(arg_bufnrs, v) != -1 })
        if !empty(contained_args)
            call execute(tab_index ..'tabclose')
        endif
    endfor
endf

" Only diff the first two args. Does it make sense to diff more?
function! david#diff#diff_args_in_tab(should_close_first)
    let lazyredraw_bak = &lazyredraw
    let &lazyredraw = 1

    tabnew

    if a:should_close_first
        call david#diff#close_tabs_containing_args()
    endif

    rewind
    botright vsplit +next
    DiffBoth
    redraw!

    let &lazyredraw = lazyredraw_bak
endf

" For plugin ZFDirDiff {{{1

function! s:ZF_GetPaths(path)
    let absolute = ZF_DirDiffPathFormat(a:path, ':p')
    let home_relative = ZF_DirDiffPathFormat(a:path, ':~')
    let cwd_relative = ZF_DirDiffPathFormat(a:path, ':.')
    let is_under_cwd = absolute != cwd_relative
    return [is_under_cwd, cwd_relative, home_relative]
endf

" g:ZFDirDiffUI_headerTextFunc
" function name to get the header text
" return a list of string
"   Use b:ZFDirDiff_isLeft, b:ZFDirDiff_fileLeft, b:ZFDirDiff_fileRight to
"   build your header
function! david#diff#DirDiff_headerText()
    let left_paths = s:ZF_GetPaths(t:ZFDirDiff_fileLeft)
    let right_paths = s:ZF_GetPaths(t:ZFDirDiff_fileRight)
    let index = 2
    if left_paths[0] && right_paths[0]
        " Both are relative to cwd, so use cwd instead.
        let index = 1
    endif
    
    if b:ZFDirDiff_isLeft
        let path = left_paths[index]
        let side = 'LEFT'
    else
        let path = right_paths[index]
        let side = 'RIGHT'
    endif
    let text = []
    call add(text, '['.. side ..']: ' .. path .. '/')
    call add(text, '------------------------------------------------------------')
    return text
endf

" g:ZFDirDiffUI_confirmHintHeaderFunc
" function name to get the confirm hint
" return a list of string
" type:
"   * 'l2r' : sync left to right
"   * 'r2l' : sync right to left
"   * 'dl' : delete left
"   * 'dr' : delete right
"   * 'diff' : diff two path
function! david#diff#DirDiff_confirmHintHeader(fileLeft, fileRight, type)
    let left_paths = s:ZF_GetPaths(a:fileLeft)
    let right_paths = s:ZF_GetPaths(a:fileRight)
    let index = 2
    if left_paths[0] && right_paths[0]
        " Both are relative to cwd, so use cwd instead.
        let index = 1
    endif
    
    let text = []
    if !empty(a:fileLeft)
        call add(text, '[LEFT]: ' .. left_paths[index] .. '/')
    endif
    
    if !empty(a:fileLeft)
        call add(text, '[RIGHT]: ' .. right_paths[index] .. '/')
    endif
    call add(text, '------------------------------------------------------------')
    return text
endf

function! david#diff#DirDiff_DirDiffEnter()
    " zfdirdiff has no help map, so improvise. @ means buffer-local.
    nnoremap <buffer> g? :<C-u>Unite mapping -input=@\  -start-insert<CR>
endf
