" Trim leading and trailing whitespace (including newlines) from a string.
function! util#trim(s)
    return substitute(a:s, '\v^(\s|\n)*|(\s|\n)*$', '', 'g')
endfunction
