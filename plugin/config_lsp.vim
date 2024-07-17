if has('nvim')
    finish
endif

" It's hard to use ins-completion when asyncomplete pops up immediately. I use
" ins-completion in gdscript since it doesn't always know the right
" possibilities.
let g:asyncomplete_popup_delay = 750

" I use completeopt=menu,preview,menuone,longest whereas asyncomplete uses
" completeopt=menuone,noinsert,noselect. Still doesn't seem to prevent my
" input from being cleared.
"~ let g:asyncomplete_auto_completeopt = 0

" I'm using ALE, so I don't want things to conflict
let g:lsp_diagnostics_enabled = 0

" If asyncomplete is causing trouble, turn it off here. Seems like the
" wipeouts issue is fixed.
" TODO: I'm getting some bad lua completion where tons of slightly relevant
" words outweigh the contextually relevant. Turning asyncomplete off seems to
" fix, but maybe I need to upgrade my lsp.
let g:asyncomplete_enable_for_all = 0

" Try out highlighting with a big delay.
let g:lsp_highlight_references_enabled = 1
" This cannot be modified at runtime.
let g:lsp_diagnostics_highlights_delay = 4000
let g:lsp_diagnostics_signs_delay = 4000
let g:lsp_document_highlight_delay = 4000
" Prevents completion from starting after . or ->
let g:asyncomplete_min_chars = 2

" lsp doesn't cycle logs, so this file has unlimited growth. Only enable when
" debugging.
"~ let g:lsp_log_verbose = 1
"~ let g:lsp_log_file = g:david_cache_root .'/lsp.log'
"~ command! LspLog exec 'edit' g:lsp_log_file

" To make lsp replace ALE:
"~ let g:lsp_diagnostics_enabled = 1
"~ let g:lsp_signs_enabled = 1         " enable signs
"~ let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode
"~ let g:lsp_signs_error = {'text': '✗'}
"~ let g:lsp_signs_warning = {'text': '‼', 'icon': '/path/to/some/icon'} " icons require GUI
"~ let g:lsp_signs_hint = {'icon': '/path/to/some/other/icon'} " icons require GUI

" Default omnifunc to lsp.
set omnifunc=lsp#complete

" vim-lsp doesn't do anything smart to find what to hover, so make our own.
command! HoverUnderCursor LspHover expand('<cword>')

let g:lsp_settings = {}
let g:lsp_settings['omnisharp-lsp'] = {}
" See after_lsp.vim


if get(g:, "loaded_lsp_settings", 0)
    call lsp_settings#set('sumneko-lua-language-server', 'args', ["--metapath", g:david_cache_root .'/lsp/meta'])
endif


augroup david_lsp
    au!

    autocmd User lsp_server_init call david#lsp#on_lsp_server_init()

    " # lua-lsp
    " brew install luarocks
    "   or
    " scoop install luarocks # also requires visual studio for cl.exe
    " luarocks install luacheck
    " luarocks install --server=http://luarocks.org/dev lua-lsp
    "
    " # emmylua-ls
    " install openjdk
    " LspInstallServer
    " I'm currently preferring sumneko because it provides completion my work project,
    " and emmylua no longer provides completion (maybe it only worked in love2d?).
    "~ if filereadable(lsp_settings#servers_dir() .'/sumneko-lua-language-server/sumneko-lua-language-server')
    "~             \ || filereadable(lsp_settings#servers_dir() .'/emmylua-ls/emmylua-ls')
    "~     " HELLO: Turn off lua settings for working with lsp here
    "~     " vim-lsp-settings handles setup for emmylua and sumneko
    "~ endif

    " cpp/c
    " scoop install llvm
    " vim-lsp-settings handles setup for clangd, but installing via scoop gets
    " us clang-format too which ale auto configures.

    " pip install python-language-server
    " vim-lsp-settings handles setup for pyls

    " brew cask install godot
    if filereadable('/Applications/Godot.app/Contents/MacOS/Godot')
        au User lsp_setup 
                    \ call lsp#register_server({
                    \ 'name': 'godot',
                    \ 'cmd': ["nc", "localhost", "6008"],
                    \ 'allowlist': ['gdscript3', 'gdscript']
                    \ })
    endif

    " The port changed in Godot4.
    " Remove when my PR is accepted.
    let g:lsp_settings.godot = { 'tcp': '127.0.0.1:6005'}
augroup END
