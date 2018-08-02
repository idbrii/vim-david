" Special settings for local environment
"

" Identity {{{1
" Set a different name for this location
let g:snips_me = 'idbrii (idbrii@.com)'
let g:snips_company = 'idbrii Inc.'

if has('win32')
	let g:snips_author = expand('$USERNAME')
else
	let g:snips_author = expand('$USER')
endif

" Config {{{1

if has('win32')
	" Prefer unix even though we're on Windows.
	"~ set fileformats=unix,dos
    " OR
    " Prefer to avoid line ending changes with other Windows users. Overrides
    " scriptease (not sure where it sets?)
	set fileformats=dos,unix
    " Use unix for vimfiles and my other config.
    augroup FileFormatDaveconfig
        au!
        au BufNewFile */daveconfig/* setlocal fileformat=unix
        au BufNewFile */.vim/* setlocal fileformat=unix
    augroup END
endif

let g:david_project_root = 'c:/p4/main'
let g:david_project_filelist = 'c:/p4/main/filelist'

" Turn off plugins {{{1
" Can't use pathogen_blacklist from here. Need to use $VIMBLACKLIST for
" local-only removal. See also before_vimrc.
let loaded_unreal = 0

" Perforce {{{1
" When I use perforce, these need to be setup.
let g:p4Presets = 'perforce:1666 idbrii_client idbrii'
let g:external_diff = 'bcomp.bat'

" When Perforce is slow:
let g:p4EnableActiveStatus = 0
let g:p4EnableRuler = 0

" Enable my p4 customizations
let g:DAVID_local_root = "c:/p4/main"
let g:p4ClientRoot = g:DAVID_local_root

" Ctrlp {{{1

" Exclude logs too
" TODO: For this to work, local.vim needs to be sourced after
" config_navigation.vim
"~ let g:ctrlp_mruf_exclude = '.*\\\.git\\.*\|^\a:\\temp\\.*\|\\AppData\\Local\\Temp\\\|\\build\\.*\\logfiles\\'
let g:ctrlp_mruf_case_sensitive = 0

" Probably not using android_ctrlp.vim
let loaded_android_ctrlp = 1

" C++ {{{1

" If most code has a path like: p4\game\main\packages\core\game\dev\src\
let g:cpp_header_n_dir_to_trim = 8
" After first or last include?
"let g:cpp_header_after_first_include = 1

" Lua {{{1

let g:inclement_n_dir_to_trim = 4
let g:inclement_after_first_include = 1

" Setup cscope for general use
if has("cscope")
    " Sometimes cscope is replaced with mlcscope (old cygwin).
	if !executable(&cscopeprg) && executable('mlcscope')
		set cscopeprg=mlcscope
	endif

    """"" Load cscope database if we can
    " disable verbose for our initial load
    set nocscopeverbose

    " add any database in current directory
    if filereadable("cscope.out")
        let g:cscope_database = 'cscope.out'

    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        let g:cscope_database = $CSCOPE_DB
    endif

    if exists("g:cscope_database") && g:cscope_database != ""
        cs add g:cscope_database
        let g:cscope_relative_path = '.'
    endif

    " okay, be verbose from now on
    set cscopeverbose

endif

" Python {{{1

" Some tools that depend on system packages and complain if they're not
" installed. If you don't use them, then set these to skip loading.
let loaded_python_bike = 0
let loaded_python_ipy = 0
let loaded_python_rope = 0

if has('win32')
    " Python's usually not in the path (so builds can use their specific
    " python version), but vim plugins need python, setup python in vim.
    " Hopefully we can avoid setting PYTHONHOME/PATH otherwise build scripts
    " called from vim need to clear these variables.
    "
    " Do I use python2.7 x64 for any plugins?
    " Denite requires py3.

    "~ let g:can_set_pythonhome = 0
    "~ call david#setup_python_paths('2.7', $MY_PYTHONHOME)
    call david#setup_python_paths('2.7', 'c:/david/apps/Python/Python27')
    call david#setup_python_paths('3.6', 'c:/david/apps/Python/Python36')

    " If these calls succeed, then uncomment can_set_pythonhome above and
    " delete these tests.
    call david#python_version(2)
    call david#python_version(3)


    " Git providers (pick one) {{{1

    " Portable git is installed with SourceTree
    let PORTABLEGIT = expand('$LocalAppData/Atlassian/SourceTree/git_local/bin')

    " Portable git is installed with Github for Windows.
    " Update it with:
    "   rmdir %LocalAppData%\PortableGit_link & mklink /D %LocalAppData%\PortableGit_link %LocalAppData%\GitHub\PortableGit_d76a6a98c9315931ec4927243517bc09e9b731a0
    let PORTABLEGIT = expand('$LocalAppData/PortableGit_link/usr/bin')
    if !david#add_to_path(PORTABLEGIT)
        echoerr "Failed to find PortableGit. Did it update and change paths?"
    endif
endif
