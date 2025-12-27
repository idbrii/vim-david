if !has('win32')
    finish
endif

" Install:
"   winget install Microsoft.PowerShell --accept-package-agreements --accept-source-agreements

" :help shell-powershell config  {{{1
set noshelltemp
let &shell = 'powershell'
let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
let &shellcmdflag .= '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();'
let &shellcmdflag .= '$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
let &shellpipe  = '> %s 2>&1'
set shellquote= shellxquote=
if executable('pwsh')
    let &shell = 'pwsh'
    let &shellcmdflag .= '$PSStyle.OutputRendering = ''PlainText'';'
    " Workaround (may not be needed in future version of pwsh):
    let $__SuppressAnsiEscapeSequences = 1
endif


" Customization  {{{1

" I want to finally use forward slashes, but shellslash breaks asyncrun even
" though 2.12.9 is supposed to support it.
"~ set shellslash
" But I can use them on the cmdline!
set completeslash=slash

" Testing  {{{1
"~ let $PATH ='%USERPROFILE%\scoop\apps\git\current\usr\bin;' .. $PATH
"~ :echo 'powershell' executable('powershell') 'pwsh' executable('pwsh')
