if exists('s:loaded_ale_gdscript')
    " Only need to do this setup once. In an ftplugin to avoid loading when
    " not doing godot. If this was part of ale, we wouldn't need this at all.
    finish
endif
let s:loaded_ale_gdscript = 1

" Ale setup for godot-gdscript-toolkit
" https://github.com/Scony/godot-gdscript-toolkit

" When pushing upstream to ale, should register in autoload/ale/fix/registry.vim
execute ale#fix#registry#Add('gdformat', 'ale#fixers#gdformat#Fix', ['gdscript'], "gdformat for Godot's gdscript")

" Should be in bundle/ale/ale_linters/gdscript/gdlint.vim
call ale#Set('gdscript_gdlint_executable', 'gdlint')
call ale#Set('gdscript_gdlint_options', '')

call ale#linter#Define('gdscript', {
            \   'name': 'gdlint',
            \   'output_stream': 'both',
            \   'executable': {b -> ale#Var(b, 'gdscript_gdlint_executable')},
            \   'command': function('ale_linters#gdscript#gdlint#GetCommand'),
            \   'callback': 'ale#handlers#unix#HandleAsWarning',
            \})
