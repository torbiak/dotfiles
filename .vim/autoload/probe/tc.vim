let s:cached_tcs = []
function! probe#tc#scan()
    redraw
    echo 'Scanning...'
    let repoRoot = s:trim(system("git rev-parse --show-toplevel"))
    let searchDirs = printf('%s/yycli/testcases', repoRoot)
    if empty(s:cached_tcs)
        let tcs = split(system("find -L " . searchDirs . " -name \"*.py\" | xargs awk '/QC_ID = / { print $3 \":\" ARGV[ARGIND]}'"))
        for tc in tcs
            let components = split(tc, ':')
            if len(components) != 2
                continue
            endif
            let [qc_id, filepath] = components
            let filepath = fnamemodify(filepath, ':.')
            cal add(s:cached_tcs, printf('%s:%s', qc_id, filepath))
        endfor
    endif
    return s:cached_tcs
endfunction

function! probe#tc#open(name)
    let fname = join(split(a:name, ':')[1:]) " Strip QC_ID
    exe printf('edit %s', fname)
endfunction

function! probe#tc#refresh()
    let s:cached_tcs = []
    cal probe#tc#scan()
endfunction

" Trim leading and trailing whitespace (including newlines) from a string.
function! s:trim(s)
    return substitute(a:s, '\v^(\s|\n)*|(\s|\n)*$', '', 'g')
endfunction
