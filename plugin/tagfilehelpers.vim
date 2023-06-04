" Quick tagfile locate functions
"
" Call locate function to search for the corresponding tagdatabase and set it.
" Author: David Briscoe
"
if exists("g:loaded_tagfilehelpers")
    finish
endif
let g:loaded_tagfilehelpers = 1

command! -bar BuildTags         call david#tagfile#BuildTags(0)
command! -bar AsyncRebuildTags  call david#tagfile#BuildTags(1)
command! -bar LocateAllTagFiles call david#tagfile#LocateAll()
