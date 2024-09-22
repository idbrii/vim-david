" When this is working well, should push up to ale.

" gdformat from godot-gdscript-toolkit
" https://github.com/Scony/godot-gdscript-toolkit
call ale#Set('gdscript_gdformat_executable', 'gdformat')
call ale#Set('gdscript_gdformat_options', '')

function! ale#fixers#gdformat#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'gdscript_gdformat_executable')
    let l:options = ale#Var(a:buffer, 'gdscript_gdformat_options')

    if &textwidth > 0 && stridx(l:options, "line-length") == -1
        let options .= " --line-length=".. &textwidth
    endif

    if &expandtab && stridx(l:options, "use-spaces") == -1
        let options .= " --use-spaces=".. &shiftwidth
    endif

    let l:cmd = printf("%s %s %%t", ale#Escape(l:executable), l:options)
    return {
        \   'command': l:cmd,
        \   'read_temporary_file': 1,
        \   'process_with': "ale#fixers#gdformat#fix_cb",
        \ }
endfunction

" Callback after running ALEFix. See :h ale-fix
function! ale#fixers#gdformat#fix_cb(buffer, output) abort
    let lines = []
    if &expandtab
        " gdformat doesn't support spaces, so manually expand tabs.
        for line in a:output
            let line = substitute(line, '^\s*\t', '    ', "")
            call add(lines, line)
        endfor
    else
        let lines = a:output
    endif
    return lines
endf
