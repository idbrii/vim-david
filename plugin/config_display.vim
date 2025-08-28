" Mappings   {{{1
" Toggle conceal
nnoremap <Leader>vcon <Cmd>let &l:conceallevel = 2 - &l:conceallevel<CR>

" Font   {{{1

function! s:SetFont(font, allow_ligatures)
    let &guifont = a:font

    " I was working with a bunch of arabic text and needed something to
    " support it. Fira Code supports arabic with directx, but instead of
    " fixed-width they're centred.
    " Fira Code only supports digraphs with directx.
    " Using directx may be slower (for cursorline or relativenumber).
    if exists('+renderoptions')
        if a:allow_ligatures
            set renderoptions=type:directx
        else
            set renderoptions&
        endif
    endif
endf



" # Font conclusions
" See also waitingroom/fonts.vim for more.
"
" Small font (fixed size. blurry when scaled.)
" >> Love it
" From http://www.proggyfonts.net/download/
"set guifont=ProggyCleanTT:h12:cANSI

" Bigger font (scalable)
" >> Looks pretty good.
" Using ttfs from https://github.com/mozilla/Fira/releases/tag/4.202
"~ set guifont=Fira_Mono:h11:cANSI:qDRAFT
" >> Fira with ligatures and slightly bolder/brighter.
" Using ttfs from https://github.com/tonsky/FiraCode/releases/tag/1.205
"~ set guifont=Fira_Code:h11:cANSI:qDRAFT

" Call from glocal.vim
command! FontDefault     call s:SetFont('Fira_Code:h11:cANSI:qDRAFT', 1)
if exists("g:goneovim") && g:goneovim
    " goneovim displays 11 px too large since ~v0.6.10. I think v0.6.3 didn't
    " have that problem.
    command! FontDefault     call s:SetFont('Fira_Code:h09:cANSI:qDRAFT', 1)
endif

command! -count=20 FontPresent        set guifont=Fira\ Code:h<count>

" Ligatures are sometimes confusing (lua's ~=). Directx's alignment makes
" ja/zh hard to follow.
command! FontNoFancy call s:SetFont('Fira_Mono:h11:cANSI:qDRAFT', 0)
" Alternatively, we can use an uglier font that's better at nonenglish (arabic).
command! FontForForeign  call s:SetFont('DejaVu_Sans_Mono:h11:cANSI:qDRAFT', 1)


" Lua   {{{1

" I find ~= confusing every time I come back and ligatures make it worse
" because they focus on math symbols instead of code operators.
let g:lua_syntax_fancynotequal = 1

" Json   {{{1
" Only want luarefvim for its doc files.
let g:vim_json_syntax_conceal = 0  " Hiding quotes is neat, but annoying when editing.
"~ let g:vim_json_warnings = 0

" Markdown   {{{1

" cpp-dosini are the default set.
let g:vim_markdown_fenced_languages = [
            \ "c++=cpp",
            \ "viml=vim",
            \ "vim=vim",
            \ "bash=sh",
            \ "ini=dosini",
            \ "lua=lua",
            \ ]

" Mark {{{1
let g:mw_no_mappings = 1
if has('gui_running')
    " Palette 'original' uses something close to my IncSearch colour. Deal
    " with it for faster cmdline startup, but modify it in gui to strip out
    " colours that look like IncSearch. (Could just use 'extended', but I like
    " 'maximum's colours more.)
    let g:mwDefaultHighlightingPalette = 'mine'
    let g:mwPalettes = {
                \   'mine': mark#palettes#Maximum()[1:],
                \   'extended': function('mark#palettes#Extended'),
                \   'soft': function('mark#palettes#Soft'),
                \ }
endif
nmap <unique> <silent> <Leader>m <Plug>MarkSet
vmap <unique> <silent> <Leader>m <Plug>MarkSet
nmap <unique> <silent> <Leader>M <Plug>MarkAllClear


" Nrrwrgn {{{1

" Default is full screen narrow. I usually narrow to limit the application of
" substitutions without worrying about setting the range. Also, use n as the
" narrow prefix.
xmap <unique> <Leader>nr <Plug>NrrwrgnBangDo
nmap <unique> <Leader>nr :<C-u>WidenRegion!<CR>
xmap <unique> <Leader>nR <Plug>NrrwrgnDo

" Narrow multiple regions
xmap <unique> <Leader>nm :NRPrepare<CR>
nmap <unique> <Leader>nm :<C-u>NRMulti<CR>


