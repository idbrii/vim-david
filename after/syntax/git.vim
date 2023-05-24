
" To match my gitconfig: date=format-local:%Y-%m-%d %a %r
" Looks like: 2023-01-11 Wed 10:27:30 AM
syn match  gitDate      /\v\d{4}-\d\d-\d\d <\u\l\l \d\d:\d\d:\d\d [AP]M>/ contained contains=@NoSpell
