function! david#incrementor#reset_incrementing_number(...)
    " First arg is the initial value.
    if a:0 > 0
        let s:incrementor_value = a:1
    else
        let s:incrementor_value = 0
    endif

    " Second arg is amount to increment by.
    if a:0 > 1
        let s:incrementor_increment = a:2
    else
        let s:incrementor_increment = 1
    endif

    " We increment before use, so decrement up front.
    let s:incrementor_value -= s:incrementor_increment

    echo 'Use a command like %sm//\=david#incrementor#get_incrementing_number() . submatch(0)'
endf
function! david#incrementor#get_incrementing_number()
    let s:incrementor_value += s:incrementor_increment
    return s:incrementor_value
endf

function! s:build_substitution(first_line, last_line, initial_number, delta)
    silent call david#incrementor#reset_incrementing_number(a:initial_number, a:delta)
    let range = a:first_line .','. a:last_line
    return range . 'sm,\v\zs\d+\ze,\=david#incrementor#get_incrementing_number(),'
endf

" Insert numbers at the beginning of the line.
function! david#incrementor#insert_leading_numbers(first_line, last_line, initial_number)
    exec s:build_substitution(a:first_line, a:last_line, a:initial_number, 1)
endf

" Queue up a regex for inserting numbers.
"   prep_regex(first_line, last_line, initial_number, increment_delta)
function! david#incrementor#prep_regex(first_line, last_line, initial_number, ...)
    let increment_delta = get(a:000, 0, 1)
    let sub_cmd = s:build_substitution(a:first_line, a:last_line, a:initial_number, increment_delta)
    " Adjust cursor so user can start typing or editing query.
    let end_of_query_idx = stridx(sub_cmd, '\ze')
    let move_to_query = repeat("\<Left>", len(sub_cmd) - end_of_query_idx)
    call feedkeys(':'. sub_cmd . move_to_query)
    " Sometimes this doesn't show, but I don't know why.
    call david#window#popup_atcursor([printf("Incrementor: Starting at %i and incrementing by %i.", a:initial_number, increment_delta)], opts)
endf
