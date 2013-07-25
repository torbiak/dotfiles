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
