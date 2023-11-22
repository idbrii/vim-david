" Compiler:	python that builds C++ with msvc

if exists("current_compiler")
  finish
endif

" Use :runtime because :compiler makes vim setup CompilerSet which errors if
" it's already setup.
runtime compiler/msvc.vim
silent! unlet g:current_compiler
let c_ef = &errorformat

runtime compiler/python.vim
silent! unlet g:current_compiler

" Prepend so C errors are recognized first.
let &errorformat=c_ef ..','..&errorformat

" Let me add my own error messages. Use a slightly nonstandard format to avoid
" collisions.
setlocal errorformat+=%f:0:%m


let g:current_compiler = 'py_msvc'

" vim:set sw=2 sts=2:
