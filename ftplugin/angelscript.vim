" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Looks mostly like C++, so most options should be the same.
runtime! ftplugin/cpp.vim
