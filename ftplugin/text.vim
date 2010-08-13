" Use spell checking for writable files
if !&readonly
    set spell
endif

" Text files probably have no useful syntax, so use manual
set foldmethod=manual

" Text files might have numbered lists
setlocal formatoptions+=n
