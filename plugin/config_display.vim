
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


" I find ~= confusing every time I come back and ligatures make it worse
" because they focus on math symbols instead of code operators.
let g:lua_syntax_fancynotequal = 1


" cpp-dosini are the default set.
let g:vim_markdown_fenced_languages = [
            \ "c++=cpp",
            \ "viml=vim",
            \ "vim=vim",
            \ "bash=sh",
            \ "ini=dosini",
            \ "lua=lua",
            \ ]
