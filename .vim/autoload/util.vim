" Trim leading and trailing whitespace (including newlines) from a string.
function! util#trim(s)
    return substitute(a:s, '\v^(\s|\n)*|(\s|\n)*$', '', 'g')
endfunction

" Return a list of [index, field] lists.
function! util#enumerate(iterable)
    let i = 0
    let items = []
    for item in a:iterable
        cal add(items, [i, item])
        let i += 1
    endfor
    return items
endfunction

" Current paragraph line range string
function! util#cpar_line_range_str()
    let first = search('^$', 'bnW') + 1
    let last = search('^$', 'nW')
    let last = last ? last - 1 : line('$')
    return printf('%s,%s', first, last)
endfunction
