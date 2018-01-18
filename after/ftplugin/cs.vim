" Similar to standard one, but since C# is a namespace containing a class
" containing functions, we need to handle more indentation. Fortunately, lines
" end with ; so we can discard false positives.
nnoremap <buffer> <C-g><C-g>  :<C-u>let last_search=@/<Bar> ?\v^(    ){0,2}\w.*[^;]$? mark c<Bar> noh<Bar> echo getline("'c")<Bar> let @/ = last_search<CR>

