" Invoke with:
" vim -Nu ~/.vim/reprovimrc.vim -U NONE

" all plugins should work with sensible as a baseline.
let s:plugins = ['sensible']

" Vimscript debugging tools.
let s:plugins += ['lookup']
let s:plugins += ['scriptease']
let s:plugins += ['vader']

" Plugins to test here ------------------------------------------

let s:plugins += ['matchup']

" To add all plugins:
"~ put =map(systemlist('ls ~/.vim/bundle'), { i,p -> printf('let s:plugins += [\"%s\"]', p)})
" /end ----------------------------------------------------------

set runtimepath-=~/.vim
set runtimepath-=~/.vim/after
set runtimepath-=~/vimfiles
set runtimepath-=~/vimfiles/after
for plugin in s:plugins
    exec "set runtimepath^=~/.vim/bundle/". plugin
    exec "set runtimepath+=~/.vim/bundle/". plugin ."/after"
endfor
set viminfofile=NONE

set hlsearch
colorscheme desert

" Core mappings that are hard to use vim without
let mapleader=' '
inoremap <C-l> <Esc>
nnoremap <Leader>w <C-w>
nnoremap <Leader>fs :update<CR>
set ignorecase smartcase
set wildmode=longest:list,full
set tag=./tags;/
source ~/.vim/plugin/config_navigation.vim

" My vim filetype
augroup reprovim
    au!
    autocmd FileType vim source ~/.vim/after/ftplugin/vim.vim
augroup END

" Load python and unix tools from local.vim
source ~/.vim/autoload/david.vim
source ~/.vim/local.vim
"~ let $PATH = $PATH .. ';' .. expand('$USERPROFILE/scoop/apps/python39/3.9.1/')

source ~/.vim/plugin/config_display.vim
FontDefault

nnoremap <buffer> <Leader>vso <Cmd>update<bar> Vader<CR>
