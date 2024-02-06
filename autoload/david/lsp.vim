function! david#lsp#on_lsp_server_init() abort
    " Instead of one autocmd per buffer pointing to their loader function,
    " setup a single autocmd and function.
    if &filetype == "lua"
        call david#lua#lsp#LoadConfigurationForWorkspace()
    endif
endf
