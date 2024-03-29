" Use spell checking for writable files that probably aren't logs.
if !&readonly && expand('%:t') !~? '\Alog\A'
    setlocal spell
endif

" Text files probably have no useful syntax, so use manual
if &foldmethod != 'diff'
    setlocal foldmethod=manual
endif

" Text files might have numbered lists
setlocal formatoptions+=n

" Wrap automatically at 78 chars.
" I pulled this from my vimrc, but it was disabled. Leave it that way for now.
"setlocal tw=78 fo+=t

" English isn't case-sensitive. Use my original case when completing.
setlocal infercase
