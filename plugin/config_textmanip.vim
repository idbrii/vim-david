" Selection {{{1
" gc selects previously changed text. (|gv| but for modification.)
nnoremap gc :<C-U>silent!normal!`[v`]<CR>
xnoremap gc `]o`[

" select all
nnoremap <C-a> 1GVG

" Reverse text
xnoremap g! "cc<C-r>=@c->split('.\zs')->reverse()->join('')<CR><Esc>
nmap g! mcviwg!`c

" Define operator as default
nmap g= <Plug>ScripteaseFilter
xmap g= <Plug>ScripteaseFilter

" gJ: join and *remove* spaces.
nnoremap gJ <Cmd>call david#editing#join_spaceless_normal()<CR>
xnoremap gJ :call david#editing#join_spaceless_visual()<CR>

let g:scriptease_prefilter = 'david#editing#ScripteasePreFilter_StripSuffix'
let g:scriptease_postfilter = 'david#editing#ScripteasePostFilter_StripSuffix'
nnoremap g== <Cmd>call david#editing#FilterNumbersFromWords(v:count)<CR>

" Quick sort (haha) {{{1
xnoremap <Leader>s  <nop>
xnoremap <Leader>s; :sort 
xmap <unique> <Leader>ss <Plug>(operator-sort)
xmap <unique> <Leader>so <Plug>(operator-sort)
xmap <unique> <Leader>sn <Plug>(operator-sort-numeric)

nmap <unique> <Leader>so <Plug>(operator-sort)
nmap <unique> <Leader>sn <Plug>(operator-sort-numeric)


" Swapping text {{{1
" Exchange {{{2

" I only want to remap ExchangeLine, so I can just do the one.
let g:exchange_no_mappings = 1
nmap <Leader>x     <Plug>(Exchange)
xmap <Leader>x     <Plug>(Exchange)
nmap <Leader>xc    <Plug>(ExchangeClear)
nmap <Leader>x<CR> <Plug>(ExchangeLine)

nmap cx <Plug>(exchange-dwim)

" Coerce {{{2

" Augment Abolish's Coerce to work in visual mode to change
" whitespace-separated content into something usable with coerce.
" Using setreg instead of expr register ensures proper newline handling (for
" comments and bullets) and maintaining selection region.
vnoremap <Leader>crt "cy:call setreg('c', david#editing#ToTitleCase(@c), getregtype(''))<CR>gv"cPgv
vnoremap <Leader>crs "cy:call setreg('c', david#editing#ToSnakeCase(@c), getregtype(''))<CR>gv"cPgv


" Sideways {{{2

" Use Sideways over Argumentative. Sideways does nothing when it can't figure
" out what to do (when there aren't matching braces). It seems to handle some
" missing braces okay sometimes too (argumentative often jumped to the end of
" a block several lines away).
"
" Sideways doesn't support visual or operator pending maps for left/right (it
" clears visual selection when using SidewaysJump), but I've never used that
" feature of argumentative.

nnoremap [, :SidewaysJumpLeft<CR>
nnoremap ], :SidewaysJumpRight<CR>
nmap <, <Plug>SidewaysLeft
nmap >, <Plug>SidewaysRight

xmap i, <Plug>SidewaysArgumentTextobjI
xmap a, <Plug>SidewaysArgumentTextobjA
omap i, <Plug>SidewaysArgumentTextobjI
omap a, <Plug>SidewaysArgumentTextobjA


" speeddating {{{1
" change increment to allow select all
nnoremap <C-x><C-s> <C-a>
nnoremap <C-x><C-x> <C-x>
xnoremap g<C-x><C-s> g<C-a>
xnoremap g<C-x><C-x> g<C-x>
" Don't let speeddating override the above. (They'll be properly mapped later
" if speeddating loads.)
let g:speeddating_no_mappings = 1


" Surround {{{1

" Use r for [right-angle braces] and a for <angle braces> like vim-surround
vnoremap ir i]
vnoremap ar a]
vnoremap ia i>
vnoremap aa a>
onoremap ir i]
onoremap ar a]
onoremap ia i>
onoremap aa a>


" Commentary {{{1

let g:commentary_marker = '~'

" Use common g prefix with / as an easy-to-type comment character.
xmap <unique> g/  <Plug>Commentary
nmap <unique> g/  <Plug>Commentary
omap <unique> g/  <Plug>Commentary
" Too many conflicts and g/w seems to do the same?
"nmap <unique> g/c <Plug>CommentaryLine
" Overlaps with textobj-comment.
"nmap <unique> cg/ <Plug>ChangeCommentary
nmap <unique> g/.  <Plug>Commentary<Plug>Commentary
nmap <unique> g/g/ <Plug>Commentary<Plug>Commentary

" Table-mode {{{1
"
" Change mode -- table mode
" I use it so frequently, that I don't need it on a short prefix.
let g:table_mode_map_prefix = '<Leader>ct'


" text_obj {{{1
let g:textobj_between_no_default_key_mappings = 1
xmap am  <Plug>(textobj-between-a)
omap am  <Plug>(textobj-between-a)
xmap im  <Plug>(textobj-between-i)
omap im  <Plug>(textobj-between-i)

" Use textobj-comment to select text in a comment (i/) and comment with
" delimeters and surrounding whitespace (a/). I'm not using comment with just
" delimeters.
let g:textobj_comment_no_default_key_mappings = 1
xmap i/  <Plug>(textobj-comment-i)
omap i/  <Plug>(textobj-comment-i)
xmap a/  <Plug>(textobj-comment-big-a)
omap a/  <Plug>(textobj-comment-big-a)

" filtering {{{1
" Convert python's logging output to a much simpler format.
command! LogStripPythonLogging %s/\v^\S\U*<(\u)\u+/\1

function! <SID>LogFilter_options(ArgLead, CmdLine, CursorPos) abort
    return [
          \ 'DEBUG',
          \ 'INFO',
          \ 'WARNING',
          \ 'ERROR',
          \ 'CRITICAL',
          \]
endf
command! -nargs=1 -complete=customlist,<SID>LogFilter_options LogFilter exec 'Unite -input=^<args> -start-insert line'
