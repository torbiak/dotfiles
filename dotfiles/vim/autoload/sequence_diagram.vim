" Idempotent sequence diagram formatter.
"
" Turns this:
"   car  engine  wheels
"   |start()->||
"   ||turn()->|
"   ||<-|
"   |<-||
"
" Or this:
"   car  engine  wheels
"   start()
"       turn()
"       <-
"   <-
"
" Into this:
"   car      engine   wheels
"    |start()->|        |
"    |         |turn()->|
"    |         |<-------|
"    |<--------|        |
"
" Headings must be separated by at least 2 spaces.
" Each line must have the same number of columns.
" After changing a heading or message name run SequenceDiagram again to
" reformat the diagram.
"
" An ok way to map keys to it:
" nn <leader>mr :normal! vip:cal sequence_diagram#format()
" vn <leader>mr :cal sequence_diagram#format()<cr>


let s:min_header_spacing = 2
let s:min_arrow_len = 2
let g:jt_sd_indent = '    '

function! sequence_diagram#format() range
    let headings = split(getline(a:firstline), '\v {2,}')
    let ncols = len(headings)

    let body = []
    for line in getline(a:firstline + 1, a:lastline)
        cal add(body, s:line2fields(line, ncols))
    endfor

    let col_widths = s:column_widths(headings, body)

    let lines = []
    cal add(lines, s:format_headings(headings, col_widths))
    let offset = len(headings[0]) / 2
    cal extend(lines, s:format_body(body, col_widths, offset))

    cal setline(a:firstline, lines)
endfunction

function! s:format_headings(headings, col_widths)
    let formatted = []
    for i in range(len(a:headings) - 1)
        let min_width = s:min_col_width(a:headings[i], a:headings[i+1])
        let padding = a:col_widths[i] - min_width + s:min_header_spacing
        let padding = max([2, padding])
        cal add(formatted, a:headings[i])
        cal add(formatted, repeat(' ', padding))
    endfor
    cal add(formatted, a:headings[-1])
    return join(formatted, '')
endfunction

" offset: column to put the first vertical line in
function! s:format_body(body, col_widths, offset)
    let lines = []
    for fields in a:body
        let formatted = []
        cal add(formatted, repeat(' ', a:offset))
        cal add(formatted, '|')
        for i in range(len(fields))
            let field = util#trim(fields[i])
            let matches = matchlist(field, '\v(\<-+)?([^-]+)?(-+\>)?')
            let left_arrow = matches[1]
            let name = util#trim(matches[2])
            let right_arrow = matches[3]
            if !len(field)
                cal add(formatted, repeat(' ', a:col_widths[i]))
                cal add(formatted, '|')
                continue
            endif
            if !len(left_arrow) && !len(right_arrow)
                let right_arrow = '->'
            endif
            let padding = a:col_widths[i] - s:min_arrow_len - len(name)
            if len(left_arrow)
                cal add(formatted, '<-')
                cal add(formatted, repeat('-', padding))
            endif
            cal add(formatted, name)
            if len(right_arrow)
                cal add(formatted, repeat('-', padding))
                cal add(formatted, '->')
            endif
            cal add(formatted, '|')
        endfor
        cal add(lines, join(formatted, ''))
    endfor
    return lines
endfunction

function! s:column_widths(headings, body)
    let col_widths = []
    " Find min column widths, considering the headings.
    for i in range(len(a:headings) - 1)
        cal add(col_widths, s:min_col_width(a:headings[i], a:headings[i+1]))
    endfor
    " Find column widths that will accomodate the message names.
    for fields in a:body
        for i in range(len(fields))
            let field = fields[i]
            let matches = matchlist(field, '\v(\<-+)?([^-]+)(-+\>)?')
            if len(matches) == 0
                continue
            endif
            let left_arrow = matches[1]
            let name = util#trim(matches[2])
            let right_arrow = matches[3]
            if len(left_arrow) && len(right_arrow)
                throw printf('Unexpected double arrow: "%s"', field)
            endif
            let min_width = len(name) + s:min_arrow_len
            let col_widths[i] = max([col_widths[i], min_width])
        endfor
    endfor
    return col_widths
endfunction

function! s:line2fields(line, nheadings)
    if a:line =~ '\v^ *\|'
        return s:formatted_line2fields(a:line, a:nheadings)
    else
        return s:terse_line2fields(a:line, a:nheadings)
    endif
endfunction

function! s:terse_line2fields(line, nheadings)
    let fields = repeat([''], a:nheadings - 1)
    let normalized = substitute(a:line, g:jt_sd_indent, "\t", 'g')
    let indent = len(matchstr(normalized, "^\t*"))
    let fields[indent] = util#trim(a:line)
    return fields
endfunction

function! s:formatted_line2fields(line, nheadings)
    let fields = split(a:line, '|', 1)
    if len(fields) - 1 != a:nheadings
        throw printf('Has %d but needs %d columns: "%s"', len(fields) - 1, a:nheadings, a:line)
    endif
    if fields[0] !~# ' *'
        throw printf('Line must start with pipe or whitespace: "%s"', a:line)
    endif
    if fields[-1] != ''
        throw printf('Line must end with pipe: "%s"', a:line)
    endif
    return fields[1:-2]  " skip first and last fields
endfunction

" Find the minimum column width that will accomodate the given headings.
function! s:min_col_width(h1, h2)
    let right_even_adjust = (len(a:h2) % 2 == 0 ? -1 : 0)
    return len(a:h1)/2 + s:min_header_spacing + len(a:h2)/2 + right_even_adjust
endfunction
