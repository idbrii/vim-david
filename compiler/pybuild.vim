" Compiler:	python that builds C++ with msvc

" TODO: Test me

if exists("current_compiler")
  finish
endif

compiler msvc
let c_ef = &errorformat
compiler python
" Prepend so C errors are recognized first.
let &errorformat=c_ef ..','..&errorformat


" vim:set sw=2 sts=2:
