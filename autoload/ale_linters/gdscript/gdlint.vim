" gdlint from godot-gdscript-toolkit
" https://github.com/Scony/godot-gdscript-toolkit
function! ale_linters#gdscript#gdlint#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'gdscript_gdlint_options')
    return '%e ' .. l:options .. ' %s'
endfunction
