
if get(g:, "lsp_loaded", 0) && lsp#get_server_status('pyls') == 'running'
    setlocal omnifunc=lsp#complete
endif

