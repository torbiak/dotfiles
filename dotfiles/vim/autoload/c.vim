" Order C functions in the same order as the given declarations. Deletes
" functions from the current buffer and inserts them, reordered, at the
" current line.
function! c#order_defs(decls)
    let names = s:c_decls_to_names(split(a:decls, "\n"))
    let lines = []
    for name in names
        cal extend(lines, s:rm_c_func(name))
    endfor
    cal append(line('.'), lines)
endfunction

function! s:c_decls_to_names(decls)
    let names = []
    for line in a:decls
        if line =~ '\v^(//|/\*|$)'
            continue
        endif
        let m = matchlist(line, '\v ([a-zA-Z0-9_]+)\(')
        if len(m) == 0
            echoerr "no name found: " . line
            continue
        endif
        cal add(names, m[1])
    endfor
    return names
endfunction

" rm_c_func removes a C function definition from the current buffer and
" returns it as a list of lines. Assumes the function name begins a line.
function! s:rm_c_func(name)
    let name_line = search('^'.a:name.'\>', 'wc')
    if name_line == 0
        echoerr "rm_c_func: not found: " . a:name
        return []
    endif

    let pre_blank = search("^$", 'bnW')
    if pre_blank == 0
        echoerr "rm_c_func: preceding blank line not found for " . a:name
    endif
    let brace = search("^}", "Wn")
    if brace == 0
        echoerr "rm_c_func: ending brace not found for " . a:name
    endif
    let lines = getline(pre_blank, brace)
    silent exe printf("%d,%ddelete", pre_blank, brace)
    return lines
endfunction
