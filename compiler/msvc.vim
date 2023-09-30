" Vim compiler file
" Compiler:	Microsoft Visual C

if exists("current_compiler")
  finish
endif
let current_compiler = "msvc"

" Default is a good starting errorformat for MSVC.
CompilerSet errorformat&

" Capture error and warning numbers.
" Example:
"   c:\code\proj\source\luasequencer.cpp(211): error C2146: syntax error: missing ';' before identifier 'ImVec2' [C:\code\proj\generated\game.vcxproj]
"   c:\code\proj\source\modelmanager.cpp(128): warning C4018: '<': signed/unsigned mismatch [C:\code\proj\generated\game.vcxproj]
" 
" For parallel build output, the log *file* omits the 1> prefix from the
" Output window:
"   1>c:\proj\stuff.cpp(71): error C2660: 'Stuff::Tick': function does not take 1 arguments
CompilerSet errorformat^=%f(%l):\ %trror\ C%n:\ %m
CompilerSet errorformat^=%f(%l):\ %tarning\ C%n:\ %m
