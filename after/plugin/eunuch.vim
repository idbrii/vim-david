
if !exists('g:loaded_eunuch')
    finish
endif

" I already have :Renamer and I'd like to not overload that too much. Also the
" unix command is mv, so Move is a better mnemonic.
delcommand Rename

" I don't have locate setup to index my system, so I don't want to
" accidentally trigger it. It's very close to :clo[se]
delcommand Clocate
delcommand Llocate

" My fingers are too fat to allow W and I don't use hidden, so it's not very
" useful to me.
delcommand Wall
delcommand W
