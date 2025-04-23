" Helpers for writing mnemonics for Chinese characters and creating Anki
" flashcards for characters and words.
"

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let b:undo_ftplugin = 'mapclear <buffer>'

function! MbUsage() range
    let range = a:firstline . ',' . a:lastline
    " Delete lines last, since they'd mess up the range for the previous
    " commands otherwise.
    silent exe range . 's/\vUsage \d+ - "?([^"]*)"?/- \1/'
    silent exe range . 'g/^$/d'
endfunction
command! -range=% MbUsage :<line1>,<line2>call MbUsage()
vn <buffer> <localleader>u :MbUsage<cr>

function! MbEntityCompletion(findstart, base) abort
    let entities = []
    if a:findstart
        let start = col('.') - 1
        let line = getline('.')
        while start > 0 && line[start - 1] =~ '[0-9a-zA-Z]'
          let start -= 1
        endwhile
        return start
    endif

    for f in ['props', 'actors']
        let entities += readfile(expand($"~/proj/chinese/{f}"))
    endfor

    if len(a:base) == 0
        return entities
    endif
    return matchfuzzy(entities, a:base)
endfunction
set completefunc=MbEntityCompletion

" Format the text copy-pasted from a Mandarin Blueprint "Make a movie" page.
function! MbMovieFormat() range abort
    let lines = getline(a:firstline, a:lastline)
    let fields = []
    for line in lines
        if line =~ '^$'
            continue
        elseif line =~ '^Make a Movie '
            eval fields->add(substitute(line, '^Make a Movie ', '', ''))
        elseif line =~ ':$'
            continue
        else
            eval fields->add(line)
        endif
    endfor

    let [char, keyword, pinyin, actor, set, room] = fields[:5]
    let props = fields[6:]->join(', ')

    let out = [char, keyword, pinyin]
    eval out->add($"{actor}; {set}: {room}; {props}")
    eval out->add('Movie: use the actor and props, and tie them to the set')

    exec $'{a:firstline},{a:lastline}d'
    cal append(a:firstline - 1, out)
endfunction
command! -range=% MbMovieFormat silent <line1>,<line2>call MbMovieFormat()
vn <buffer> <localleader>m :MbMovieFormat<cr>

" Bindings to echo or append() definitions for Chinese words.
nn <buffer> <localleader>d :echo system('cedict ' . expand('<cword>'))<cr>
nn <buffer> <localleader>D :call append('.', systemlist('cedict ' . expand('<cword>')))<cr>
vn <buffer> <localleader>d :<C-u>echo system('cedict ' . GetSelection('v'))<cr>
vn <buffer> <localleader>D :<C-u>call append('.', systemlist('cedict ' . GetSelection('v')))<cr>

function! CopyAsTsv() abort
    cal system('xsel -ib', getline("'<", "'>")->join("\t"))
endfunction
vn <buffer> <localleader>t :<c-u>call CopyAsTsv()<cr>
