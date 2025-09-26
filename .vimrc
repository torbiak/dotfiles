" vim:foldmethod=marker

" runtimepath {{{

" setup runtimepath to be more unixy on windows
set rtp-=~/vimfiles
set rtp+=~/.vim

let g:pathogen_disabled = ['vipyut', 'probe']
if hostname() == 'hatebox'
    cal add(g:pathogen_disabled, 'vim-go')
endif
call pathogen#infect()
call pathogen#helptags()
" }}}

" Basic options {{{

filetype plugin on
set encoding=utf-8
set tags+=.tags
set laststatus=2 ruler
set sts=-1 ts=8 sw=4 et
set ic hls smartcase incsearch
set showmatch matchtime=2  " paren-matching
set wildmode=list
set grepprg=rg\ --vimgrep\ -S
set bs=2
set complete=.,w  " stay fast by only suggesting completions from open windows
set winminheight=0
set modeline
set more
set cryptmethod=blowfish2
set vb t_vb=  " Disable bell.

" Backups
if exists("*mkdir") && !isdirectory(expand('~/tmp/vim'))
    cal mkdir(expand('~/tmp/vim'), 'p')
endif
set backup
set backupdir=~/tmp/vim,.

" Formatting options {{{

" j: remove comment markers when joining lines
" q: allow formatting comments with gq
" t: automatically break lines longer than textwidth in insert mode
" c: automatically break comment lines and insert comment marker
set formatoptions+=jq
set formatoptions-=tc
" Don't insert two spaces after sentences when joining lines.
set nojoinspaces
" Don't use Q for Ex mode, use it for formatting.
noremap Q gq
" Indent wrapped lines by the width of the bullet matched by formatlistpat
set breakindent breakindentopt=list:-1
" Don't treat bulleted lists like comments.
set comments-=fb:-
" }}}
" }}}

" Keybindings {{{

ino jk <esc>
let mapleader = 's'
let maplocalleader = '\'
nn <leader> <nop>

" When yanking quoted strings, don't include leading whitespace.
nn ya' y2i'
nn ya" y2i"

" Yank/paste
" Paste the unnamed register more conveniently.
nn <leader>p "0p
nn <leader>P "0P

nn Y y$

" Save the unnamed register into @y. Useful when you delete/yank something to
" move/copy it somewhere else, but then realize that it'd be easiest to first
" make some changes at the destination that'd overwrite @" and/or @0.
nn <leader>y :let @y = @"<cr>

" Yank current filename.
nn <leader>mf :let @" = expand('%')->substitute('^' . $HOME, '~', '') <bar> echo @"<cr>
nn <leader>mF :let @" = expand('%:p')->substitute('^' . $HOME, '~', '') <bar> echo @"<cr>

" Emacs emulation {{{

" Emacs emulation in Cmdline mode.
"
" Note that there's a small downside in mapping key sequences starting with
" <esc>, since if you hit <esc> to exit the mode vim will need to wait for
" another key or for 'timeout' to know whether you meant <esc> by itself or as
" the start of another mapping. In practice I hardly ever notice this, though.
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-D> <Del>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>
cnoremap <esc>b <S-Left>
cnoremap <esc>f <S-Right>
cnoremap <esc><bs> <C-w>

" Emacs emulation in insert mode.
inoremap <C-A> <Home>
inoremap <C-E> <End>
inoremap <C-B> <Left>
inoremap <C-F> <Right>
inoremap <C-D> <Del>
inoremap <esc>b <S-Left>
inoremap <esc>f <S-Right>
inoremap <esc><bs> <C-w>
" }}}

" Quickfix
" I don't find the default bindings for -, _, and + useful, but I use the
" quickfix list all the time.
nn - :cp<cr>
nn + :cn<cr>

" Cycle forward/backward through wildmode matches.
cnoremap <M-m> <C-N>
cnoremap <esc>m <C-N>
cnoremap <M-M> <C-P>
cnoremap <esc>M <C-P>

" Open balanced surroundings.
ino ;{ {<cr>}<esc>O
ino ;[ [<cr>]<esc>O
ino ;( (<cr>)<esc>O
ino ;" ""<esc>i
ino ;' ''<esc>i

" Arglist
nn <leader>n :wn<cr>
nn <leader>N :N<cr>

" vimrc
nn <leader>ve :e ~/.vimrc<cr>
nn <leader>vn :new ~/.vimrc<cr>
nn <leader>vs :source ~/.vimrc<cr>

" Windowing
" I often have a lot of windows open in two columns and want to navigate
" through a bunch of them quickly.
nn <c-j> <c-w>j
nn <c-k> <c-w>k

" Tab widths
nn <leader>8 :set ts=8 sw=8 et<cr>
nn <leader>4 :set ts=4 sw=4 et<cr>
nn <leader>2 :set ts=2 sw=2 et<cr>

" Jump between methods
" ]m works for opening-brace-at-beginning-of-line C functions like ]], as well
" as cuddled opening braces for Java-style methods, so make it more
" convenient.
nn ]] ]m
nn [[ [m

" Toggle settings conveniently.
nn <leader>mp :set paste!<cr>
nn <leader>h :noh<cr>

" remove trailing whitespace
nn <leader>mw :%s/\v\s+$//<cr>

" source/run the current file
nn <leader>ms :w<cr>:source %<cr>
nn <leader>x :source ~/source.vim<cr>
nn <leader>mr :!./%<cr>

" Search for current word without moving. Useful to highlight something
" while keeping the current view.
no <leader>m* :let @/ = '\<' . expand('<cword>') . '\>' \| set hlsearch<cr>
"}}}

" Indenting {{{

" A general-purpose indenting expression that I use for most languages.
"
" Cover common cases but let the user take care of anything weird, since
" trying to be comprehensive complicates the rules past predictability.
function! TorbijIndent()
    let prev_line = getline(v:lnum - 1)
    let prev_indent = indent(v:lnum - 1)
    let cur_line = getline(v:lnum)
    let inc = 0
    let dec = 0
    for p in g:inc_indent_after
        if prev_line =~# p
            let inc += &sw
            break
        endif
    endfor
    for p in g:dec_indent_on
        if cur_line =~# p
            let dec += &sw
            break
        endif
    endfor
    if inc == 0 && dec == 0
        return -1  " Defer to autoindent.
    endif
    return prev_indent + inc - dec
endfunction


" If the previous line matches one of these patterns, increment the indent of
" the current line.
let g:inc_indent_after = []
cal add(g:inc_indent_after, '[{\[\(]$')  " Trailing parens/brackets/colons.
cal add(g:inc_indent_after, '\v^\s*(class|def|async def|if|elif|while|for|with|async with|try|except)>.*(; then|; do|:)$')  " sh|Python|Nim control statements
cal add(g:inc_indent_after, '\v^\s*(else>).*:?$')  " 'else' in various languages
cal add(g:inc_indent_after, '\v^function!? \w+\(.*$')  " VimL function statements.

" If the current line matches one of these patterns, decrement its indent.
" Depends on indentkeys being set appropriately.
let g:dec_indent_on = [
    \ '^\s*[}\]\)]',
    \ '^\v\s*(else|elif|elsif)',
    \ '^\v\s*(end|done)'
\ ]
set indentkeys=0},0],0),o,O,0=end,0=done,0=else,0=elif,0=elsif
set indentexpr=TorbijIndent()
set ai nosi nocin
filetype indent off

" Lines in a paragraph that happen to start with 'if', 'else', etc will result
" in indentation. Turn off TorbijIndent before formatting to avoid this.
" Despite much effort I haven't been able to wrap gq using map-operator to
" turn off TorbijIndent automatically without breaking comment formatting (the
" indent isn't kept for comment lines following the first).
function! ToggleTorbijIndent()
    if &indentexpr ==# 'TorbijIndent()'
        let &l:indentexpr=''
        echo 'TorbijIndent off'
    else
        let &l:indentexpr='TorbijIndent()'
        echo 'TorbijIndent on'
    endif
endfunction
nn <leader>i :call ToggleTorbijIndent()<cr>
" }}}

" Display {{{

if !exists("g:syntax_on")
    " Enable syntax at startup, but don't reload highlight groups when
    " sourcing vimrc later.
    syntax enable
endif

set shortmess-=S  " show incremental search position
set guioptions='cM'
set t_Co=16  " Use terminal color palette instead of 8-bit color.
set background=dark

set list
set listchars=tab:»\ ,trail:·,

function ModColorScheme()
    " Customize colorscheme when using 4-bit color.
    if str2nr(&t_Co) == 16 && g:colors_name !=# 'forbit'
        hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE

        hi Visual ctermfg=black ctermbg=cyan cterm=NONE
        hi Search ctermfg=black ctermbg=darkgreen cterm=NONE
        hi IncSearch ctermfg=black ctermbg=lightyellow cterm=bold

        hi DiffAdd ctermfg=darkgreen ctermbg=black cterm=NONE
        hi DiffChange ctermfg=darkyellow ctermbg=black cterm=NONE
        hi DiffDelete ctermfg=darkred ctermbg=black cterm=NONE
        hi DiffText ctermfg=black ctermbg=darkyellow cterm=bold
    endif
endfunction
augroup color_mods
    au!
    au ColorScheme * call ModColorScheme()
augroup END
colorscheme forbit
" }}}

" Bracketed paste {{{

" Enable bracketed-paste for screen/tmux. Bracketed-paste isn't advertised via
" terminfo, so AFAICT vim only sets the relevant t_* settings if the builtin
" 'xterm' terminal is used or if you set them yourself.
if &term =~ '\v^(screen|tmux)'
  let &t_BE = "\e[?2004h"
  let &t_BD = "\e[?2004l"
  exec "set t_PS=\e[200~"
  exec "set t_PE=\e[201~"
endif
" }}}

" Spelling {{{

function! ToggleSpell()
    if !&spell
        set spellcapcheck=

        " Avoid checking things that are likely not to be common words.
        " Sometimes other syntax items will override these, see
        " :help syn-priority
        syn match URLNoSpell '\w\+:\/\/[^[:space:]]\+' contains=@NoSpell
        syn match CapitalizedNoSpell '\<[A-Z]\w*\>' contains=@NoSpell
        syn match PossessiveNoSpell '\<\w\+\'s\>' contains=@NoSpell
        " Embedded capital (fileList) or underscore (file_list).
        syn match IdentNoSpell '\<\w\+[A-Z_]\w\+\>' contains=@NoSpell
    endif
    set spell!
endfunction
nn <leader>= :call ToggleSpell()<cr>
" }}}

" Folding {{{
function! FoldBlocks() abort
    set foldmethod=marker foldmarker={,} foldminlines=5 foldlevel=5
endfunction
" }}}

" File/Buffer commands {{{

" Rename buffer's file.
function! Rename(dst)
    let old = expand('%')
    if (old == a:dst)
        return
    endif
    if rename(old, a:dst) != 0
       echom 'rename failed'
       return
    endif
    exe 'e!' a:dst
endfunction
command! -nargs=1 -complete=file -bar Rename call Rename('<args>')

" Delete buffer and its file.
function! Delete()
    let path = expand('%')
    bdelete
    call delete(path)
endfunction
command! -bar Delete call Delete()

function! PlusExecutable()
    silent! !chmod +x %:S
    redraw!
endfunction
command! Px cal PlusExecutable()

" I often don't release shift fast enough and accidentally type :New.
"command -nargs=? -complete=file New new <args>
" Try an abbreviation instead, which converges history.
cabbrev New new

" Evaluate arguments as globs and set the unnamed register to the resulting
" newline-separated list of filenames.
"
" Intended for easily finding files and accurately copying their paths into a
" document, instead of going to a shell and using the OS's copy-paste
" functionality. Another crude but effective way to do this (without globbing)
" while still using filename completion is to read in the results of `echo`,
" like `:r !echo ~/.bash<TAB>`.
"
" See also :h i_CTRL-X_CTRL-F, for completing filenames in insert mode.
com! -nargs=* -complete=file YankFilepaths let @" = join(GlobEach([<f-args>]), "\n")
function! GlobEach(patterns)
    let files = []
    for pattern in a:patterns
        for file in glob(pattern, 0, 1)
            let f = substitute(file, '^\V' . escape(expand("$HOME"), '\'), '\~', "")
            cal add(files, f)
        endfor
    endfor
    return files
endfunction

" }}}

" Diff {{{

" Diff current buffer with what's on disk.
function! DiffBuffer()
    let tmp = tempname()
    let absPath = fnameescape(expand('%:p'))
    exe printf('w %s', fnameescape(tmp))
    echo system(printf('diff -u %s %s', absPath, tmp))
    cal delete(tmp)
endfunction
com! DiffBuffer call DiffBuffer()

" Diff two lines in a new tab.
function! DiffLines(startline, endline) abort
    " If a one-line range is given, assume the user wants to diff the given
    " line with the next one.
    let [lnum1, lnum2] = [a:startline, a:endline]
    if lnum1 == lnum2
        let lnum2 += 1
    endif
    let line1 = getline(lnum1)
    let line2 = getline(lnum2)

    tabnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted nomodified
    cal setline(1, line1)
    diffthis

    below new
    setlocal buftype=nofile bufhidden=wipe nobuflisted nomodified
    cal setline(1, line2)
    diffthis
endfunction
command! -range DiffLines cal DiffLines(<line1>, <line2>)
" }}}

" Surround {{{

function! NormalSurround(open, close)
    normal viW<esc>
    cal VisualSurround(a:open, a:close)
endfunction
"nn <leader>mb :call NormalSurround('<tt>', '</tt>')<cr>

function! VisualSurround(open, close) range
    let startLine = getline("'<")
    let endLine = getline("'>")
    let startCol = col("'<")
    let endCol = col("'>")
    if line("'<") == line("'>")
        let before = strpart(startLine, 0, startCol - 1)
        let middle = strpart(startLine, startCol - 1, endCol - startCol + 1)
        let after = strpart(startLine, endCol)
        cal setline("'<", before . a:open . middle . a:close . after)
    else
        let before = strpart(startLine, 0, startCol - 1)
        let after = strpart(startLine, startCol - 1)
        cal setline("'<", before . a:open . after)
        let before = strpart(endLine, 0, endCol - 1)
        let after = strpart(endLine, endCol - 1)
        cal setline("'>", before . a:close . after)
    endif
    cal cursor(line("'>"), endCol + strlen(a:open) + strlen(a:close))
endfunction
vn <leader>mb :call VisualSurround('<tt>', '</tt>')<cr>
" }}}

" Templating {{{

" Using the given range as a template, generate all combinations of given
" substitutions, adding them below the given range.
"
" usage: TemplateCartesian(<pattern>, <replacements>, <pattern>, <replacements>, ...)
" eg: on a line containing 'ab':
" :.call TemplateCartesian('a', range(2), 'b', range(2))
" 00
" 01
" 10
" 11
function! TemplateCartesian(...) range
    " Organize args.
    let replacementLists = {}
    let patterns = []
    let i = 0
    while i < len(a:000)
        let pattern = a:000[i]
        cal add(patterns, pattern)
        let replacementLists[pattern] = a:000[i+1]
        let i += 2
    endwhile

    " Initialize combination state.
    " If we knew how many patterns were going to be given we could use nested
    " loops to generate the combinations, keeping the combination state in the
    " loop variables and iterators. To handle an arbitrary number of patterns
    " we instead keep the combination state in a list.
    " For example, for two patterns, each with two replacements:
    "   [0, 0] -> [0, 1] -> [1, 0] -> [1, 1]
    " Replacements are selected based on the value of 'combinations'.
    let combination = []
    for p in patterns
        cal add(combination, 0)
    endfor

    let template = join(getline(a:firstline, a:lastline), "\r")
    let lines = []

    " Generate all combinations of replacements.
    while combination[0] < len(replacementLists[patterns[0]])
        let out = template
        for pi in range(len(patterns))  " pi: pattern index
            let pattern = patterns[pi]
            let replacement = replacementLists[pattern][combination[pi]]
            let out = substitute(out, pattern, replacement, "g")
        endfor

        cal extend(lines, split(out, "\r"))

        " Increase the combination counters, carrying as necessary depending
        " on the number of replacements associated with a pattern.
        let combination[-1] += 1
        for i in range(len(combination) - 1, 1, -1)
            if combination[i] >= len(replacementLists[patterns[i]])
                let combination[i] = 0
                let combination[i-1] += 1
            endif
        endfor
    endwhile

    cal append(a:lastline, lines)
endfunction

" Using the given range as a template, generate a substitution for each set of
" replacements, adding them below the given range.
"
" usage: TemplateCartesian(<pattern>, <replacements>, <pattern>, <replacements>, ...)
" eg: on a line containing 'ab':
" :.call TemplateCartesian('a', [1, 2], 'b', [3, 4])
" 13
" 24
function! TemplateLinear(...) range
    " Organize args.
    let replacementLists = {}
    let i = 0
    while i < len(a:000)
        let pattern = a:000[i]
        let replacementLists[pattern] = a:000[i+1]
        let i += 2
    endwhile

    let nrepl = len(values(replacementLists)[0])
    for [k, v] in items(replacementLists)
        if len(v) != nrepl
            throw "wrong number of replacements for " . k
        endif
    endfor

    let template = join(getline(a:firstline, a:lastline), "\r")
    let lines = []

    for i in range(nrepl)
        " Make substitutions.
        let out = template
        for [pattern, replacements] in items(replacementLists)
            let repl = replacements[i]
            let out = substitute(out, pattern, repl, "g")
        endfor

        cal extend(lines, split(out, "\r"))
    endfor

    cal append(a:lastline, lines)
endfunction

" Assign-and-increase function intended to be used when making substitutions
" using the expression register. For example, to replace 'X's with
" 1, 2, 3, ...: let i=1 | s/X/\=Inc(1)/g
let g:i = 1
function! Inc(step)
    let g:i += a:step
    return g:i - a:step
endfunction
" }}}

" Date {{{

" Insert using CTRL-R and the expression register.
function! Date(...)
    if a:0 == 0
        let days_offset = 0
    elseif a:0 == 1
        let days_offset = a:1
    else
        throw "usage: Date([days_offset])"
    endif
    return strftime("%Y-%m-%d %a", localtime() + 86000 * days_offset)
endfunction

function! Clip(s) abort
    cal system('xsel -ib', a:s)
endfunction
" Copy the unnamed register to the clipboard.
nn <leader>" :cal Clip(@")<cr>

function! Today()
    return Date(0)
endfunction

function! Timestamp()
    return strftime("%Y-%m-%dT%H:%M")
endfunction
"}}}

" Formatting {{{

" Idempotent table formatter.
" sep: field separator pattern
" opts: dict with the following keys:
"   align: string of field alignments (eg. "llr" for Left, Left, Right)
"   newsep: new separator. Useful if regex metacharacters are present in sep.
"   ignorecomments: True/False. Leave comment lines alone.
"   ignore1fcomments: True/False. Leave comments with a single field alone.
function! Table(sep, opts) range
    let alignment = split(get(a:opts, 'align', ""), '\zs')
    let max_len = {}
    for line in getline(a:firstline, a:lastline)
        if get(a:opts, "ignorecomments", 0) && line =~ '^\v\s*(//|/\*|#).*'
            continue
        endif
        if get(a:opts, "ignore1fcomments", 0) && line =~ '^\v\s*(//|/\*|#).*' && line !~ a:sep
            continue
        endif
        for [i, field] in util#enumerate(split(line, a:sep))
            let field = substitute(field, ' *(.{-}) *', '\1', "")
            let max_len[i] = max([get(max_len, i, 0), strlen(field)])
        endfor
    endfor
    if len(max_len) == 0
        return
    endif
    let formatted = []
    for line in getline(a:firstline, a:lastline)
        if get(a:opts, "ignorecomments", 0) && line =~ '^\v\s*(//|/\*|#).*'
            cal add(formatted, line)
            continue
        endif
        if get(a:opts, "ignore1fcomments", 0) && line =~ '^\v\s*(//|/\*|#).*' && line !~ a:sep
            cal add(formatted, line)
            continue
        endif
        let fields = []
        for [i, field] in util#enumerate(split(line, a:sep))
            let field = substitute(field, ' *(.{-}) *', '\1', "")
            if get(alignment, i, 'l') == 'l'
                let format = printf('%%-%ds', max_len[i])
            else
                let format = printf('%%%ds', max_len[i])
            endif
            cal add(fields,  printf(format, field))
        endfor
        cal add(formatted, substitute(join(fields, get(a:opts, 'newsep', a:sep)), '\v *$', '', ''))
    endfor
    cal setline(a:firstline, formatted)
endfunction
nn <leader>mt :exe printf('%scal Table(" \\{2,}", {"newsep": "  "})', util#cpar_line_range_str())<cr>
vn <leader>mt :cal Table(' \{2,}', {'newsep': '  '})<cr>
command! -range AlignComments <line1>,<line2>call Table('\v +\ze[/#]', {'newsep': ' '})

function! Semicolon() range
    for i in range(a:firstline, a:lastline)
        let line = getline(i)
        if line =~ '^\s*$' | echo 'blank' | continue | endif  " blanks
        if line =~ '\v^\s*(#|//)' | echo 'scomm' | continue | endif  " comments at start
        " Skip comments at the end of a line. Try not to match comment
        " indicators in strings, though.
        if line =~ "\\v(#|//)[^'\"]*$" | echo 'ecomm' | continue | endif
        " Skip lines ending with characters that imply continuance. Also,
        " lines ending with } often don't want a semicolon.
        if line =~ '\v[\[\{,\(; \}]$' | echo 'cont' | continue | endif
        if getline(i + 1) =~ '\v^\s*\.' | echo 'chain' | continue | endif  " method chains
        cal setline(i, line . ';')
    endfor
endfunction
command! -range Semicolon <line1>,<line2>call Semicolon()
nn <leader>; :Semicolon<cr>
vn <leader>; :Semicolon<cr>

function! RightAlignSecondField()
    let line = getline('.')
    let tw = &textwidth == 0 ? 78 : &textwidth
    let fields = split(line, '\v {2,}')
    if len(fields) > 2
        throw 'Too many fields.'
    endif
    let pad_width = tw - len(fields[0]) - len(fields[1])
    cal setline('.', fields[0] . repeat(' ', pad_width) . fields[1])
endfunction

" Convert a path selected in visual mode to quoted list items.
" eg: /a/b/c -> 'a', 'b', 'c'
function! PathToQuoted()
    let line = getline('.')
    let start = col("'<")
    let len = col("'>") - start + 1
    let path = strpart(line, start - 1, len)
    let quoted = "'" . join(split(path, '/'), "', '"). "'"
    cal setline('.', strpart(line, 0, start - 1) . quoted . strpart(line, start + len - 1))
endfunction
nn <leader>mq :call PathToQuoted()<cr>

function! SnakeToCamel()
    s/\v_([a-z])/\u\1/g
endfunction

function! ArgsOnSeparateLines()
    let base_indent = matchstr(getline('.'), '\v^[ \t]*')
    let indent = base_indent . repeat(' ', shiftwidth())
    silent s/\v, /\=",\n" . indent/g
endfunction

" Copy Javascript code to the clipboard in a format suitable for using as a
" bookmarklet in Firefox.
"
" AFAICT only newlines need to be percent-encoded.
function! CopyAsBookmarklet(start, end) abort
    let text = getline(a:start, a:end)->join("%0A")
    let text = $"javascript: (function() {{{text}}})()"
    cal system('xsel -ib', text)
endfunction

" Join lines, trimming whitespace from all but the first.
function! JoinNoWhitespace() range abort
    " Modify the range so that when JoinNoWhitespace() is called on a single
    " line range it joins it with the next line.
    let first = a:firstline
    let last = first == a:lastline ? first + 1 : a:lastline
    let joined = getline(first, last)
        \->map({ i, line -> i == 0 ? line : line->trim('', 1) })
        \->join('')
    exe $'{first},{last}d'
    cal append(first - 1, joined)
endfunction
command! -range JoinNoWhitespace <line1>,<line2>call JoinNoWhitespace()

" }}}

" Viewing {{{

" View images
"
" It seems more convenient to use <cfile> instead of expecting an operator for
" the common case. For filenames with spaces you'll need to visually select it
" first, unless it's on a line by itself, in which case the  `mV` binding is
" appropriate.
let g:ViewCmd = 'feh --scale-down'
nnoremap <leader>mv :echo system(g:ViewCmd . ' ' . expand('<cfile>') . ' &')<cr>
nnoremap <leader>mV :<c-u>echo system(g:ViewCmd . ' ' . fnameescape(GetSelection(visualmode())) . ' &')<cr>
vnoremap <leader>mv :<c-u>echo system(g:ViewCmd . ' ' . fnameescape(GetSelection(visualmode())) . ' &')<cr>

" Open links or whatever.
nnoremap <leader>mo :echo system('xdg-open ' . expand('<cfile>'))->trim()<cr>

" Make a new window and format a man page for it.
function! Man(man_args, win_mods)
    exe printf('%s new', a:win_mods)
    setlocal bufhidden=unload " unload buf when no longer displayed
    setlocal buftype=nofile   " buffer is not related to any file
    setlocal nowrap           " don't soft-wrap
    setlocal nobuflisted      " don't show up in the buffer list
    setlocal filetype=man
    " pipe in the formatted manpage
    exe printf('silent 0r !MANWIDTH=%d man %s', winwidth(0), a:man_args)
    " set a descriptive name
    exe printf('silent file %s', fnameescape('man ' . a:man_args))
    0
endfunction
com! -nargs=+ Man call Man(<q-args>, <q-mods>)
" }}}

" Highlighting {{{

" Define highlight groups with characteristics similar to IncSearch to be used
" with :match and matchadd()
"
" For example:
"
"     :match jat1 /some_pattern/  " highlight some_pattern
"     :match jat1 /other_pattern/  " highlight other_pattern instead
"     :2match jat2 /yet_another/  " also highlight yet_another
"     :match none  " clear other_pattern
"     :2match none  " clear yet_another
function! MakeJatHighlightGroups() abort
    let color_pairs = [['black', 'magenta'], ['black', 'green'], ['white', 'blue'], ['black', 'cyan']]
    let i = 1
    for [fg, bg] in color_pairs
        exe $"hi jat{i} ctermfg={fg} ctermbg={bg}"
        let i += 1
    endfor
endfunction
cal MakeJatHighlightGroups()

function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
nn <leader>5 :call SynGroup()<cr>

function! SynStack()
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
nn <leader>6 :call SynStack()<cr>

" }}}

" Printf debugging {{{

" Generate printf-style debugging calls based on variable names on the current
" line.

function! DebugVarsC(sep=' ')
    let indent_len = line('.')->indent()
    let indent = &expandtab ? repeat(' ', indent_len) : repeat("\t", indent_len / &tabstop)
    let words = getline('.')->split()
    let formats = []
    let vars = []
    for w in words
        let [_, var, spec; _] = matchlist(w, '\v(\w+)%(:(.*))?')
        cal add(vars, var)
        let spec = spec ?? 's'
        if spec == 's'
            cal add(formats, $"{var}=[%{spec}]")
        else
            cal add(formats, $"{var}=%{spec}")
        endif
    endfor
    let format = formats->join(a:sep) . '\n'
    let args = join(vars, ', ')
    let line = $"{indent}printf(\"{format}\", {args});  // TODO: remove"
    cal setline('.', line)
endfunction

function! DebugVarsPython(sep=' ')
    let indent_len = line('.')->indent()
    let indent = &expandtab ? repeat(' ', indent_len) : repeat("\t", indent_len / &tabstop)
    let words = getline('.')->split()
    let pieces = []
    for w in words
        " If no formatting was specified, add '=' to print the expr itself.
        let suffix = (match(w, '\v[!:=]') == -1) ? '=' : ''
        cal add(pieces, printf('{%s%s}', w, suffix))
    endfor
    let format = pieces->join(a:sep)
    let line = $"{indent}print(f'{format}')  # TODO: remove"
    cal setline('.', line)
endfunction

function! DebugVarsJavascript(sep=' ')
    let indent_len = line('.')->indent()
    let indent = &expandtab ? repeat(' ', indent_len) : repeat("\t", indent_len / &tabstop)
    let words = getline('.')->split()
    let pieces = []
    for w in words
        cal add(pieces, printf('%s=${%s}', w, w))
    endfor
    let format = pieces->join(a:sep)
    let line = $"{indent}console.log(`{format}`);  // TODO: remove"
    cal setline('.', line)
endfunction
" }}}

" Extracting {{{

" Extract strings from a buffer using a regex.
"
" Match a regex against a range of lines, convert each list of submatches to a
" string using the given FuncRef, and set the unnamed register to the
" resulting strings, with each on its own line.
"
" Extract(re, [func])
"
" re
"   regular expression with capture groups. Use a single-quoted string to
"   avoid doubling backslashes
" func
"   A FuncRef, or more likely a lambda expression, to combine submatches into
"   strings to be added to the returned list. The list of submatches is given
"   as the first argument. By default the entire match is returned.
"
" For example, with these lines:
"
"   foo(a, b)
"   foo(c, d)
"
" calling this:
"
"   %cal Extract('\vfoo\((\w+), (\w+)', {m -> m[1] . m[2])})
"
" results in @" being set to:
"
"   a b
"   c d
"
" Use varargs instead of a default argument for the func parameter to be
" compatible with Vim 8.0, which has lambdas but not default args.
if has('lambda')
    function! Extract(re, ...) range
        if a:0 == 0
            let Func = {m -> m[0]}
        elseif a:0 == 1
            let Func = a:1
        else
            throw "Extract expects only one extra arg"
        endif
        let l = []
        let lines = getline(a:firstline, a:lastline)
        " Going linewise in vimscript is probably pretty slow, but if we
        " combine the lines into a single string then line breaks are kind of
        " ignored (see `:h string-match`). Using the :substitute command
        " instead might be faster but it'd be awkward to get a list of
        " submatches then.
        for line in lines
            cal substitute(line, a:re, {m -> [add(l, Func(m)), m[0]][1]}, 'g')
        endfor
        cal setreg('"', join(l, "\n"), 'l')
    endfunction
endif

" Collect lines matching pattern into register g.
command! -range=% -nargs=? Collect let @g = '' | execute '<line1>,<line2>g/<args>/y G' | let @g = @g[1:]
" }}}

" Navigation {{{

function! Grep(args, open_window) abort
    " Tell :grep to never jump ('!'), but then open a new window for the
    " results if requested or the current buffer is modified.
    exe $':grep! {a:args}'
    let nhits = getqflist({'size' : 1})['size']
    if nhits && (a:open_window || &modified)
        new
        cc 1
    endif
endfunction
command! -nargs=+ -bang Grep cal Grep(<q-args>, "<bang>" == '!')
command! -nargs=+ -bang GrepRepo cal Grep(<q-args> . ' ' . fnameescape(RepoRoot()), "<bang>" == '!')
cnoreabbrev GR GrepRepo

" Grep current word.
nn <leader>g :cal Grep(expand('<cword>'), 0)<cr>
nn <c-w>g :cal Grep(expand('<cword>'), 1)<cr>
nn <leader>G :cal Grep(expand('<cword>') . ' ' . fnameescape(RepoRoot()), 0)<cr>
nn <c-w>G :cal Grep(expand('<cword>') . ' ' . fnameescape(RepoRoot()), 1)<cr>

" A weak fuzzy file finder for use in environments where installing vim
" plugins or other executables isn't possible or worth it.
"
" If a single file under the current directory contains the given substrings
" in order, edit that file in the current window. Otherwise print the files
" that matched.
"
" Surprisingly, this feels like 70% of what I need from a fuzzy file finder.
"
" eg:
"   :E parts of a file path
function! EditFileLikeSubstrings(...)
    let pattern = ''
    for arg in a:000
        let pattern .= '*' . arg
    endfor
    let pattern .= '*'
    let cmd = "find . -name .git -prune -o -type f -not -name '*.sw[opq]' -ipath %s -print"
    let files = systemlist(printf(cmd, shellescape(pattern)))
    if len(files) == 1
        exe 'e ' . files[0]
    elseif len(files) == 0
        echo 'No files matched.'
    else
        echo 'Multiple files matched:'
        for f in files
            echo f
        endfor
    endif
endfunction
command! -nargs=+ E cal EditFileLikeSubstrings(<f-args>)

" Switch between C header and implementation files.
function! HOrC(filepath)
    if a:filepath =~ '\.c$'
        exe 'e ' . substitute(a:filepath, '\.c$', '.h', '')
    else
        exe 'e ' . substitute(a:filepath, '\.h$', '.c', '')
    endif
endfunction
nn <leader>o :call HOrC(expand('%'))<cr>

" Open a file and search for a regex.
"
" Expects a "link" formatted like {<filename>:<regex>} to be under the cursor.
function! GoAndSearch()
    let saved_unnamed_reg = @"
    normal yi{
    let m = matchlist(@", '\v([^:]+):(.*)')
    if len(m) == 0
        echohl ErrorMsg | echo 'unexpected link format' | echohl None
        return
    endif
    let filename = m[1]
    let regex = m[2]
    exe 'new ' . filename
    cal search(regex)
    let @" = saved_unnamed_reg
endfunction
nn <leader>mg :call GoAndSearch()<cr>
"}}}

" Plugin configuration {{{

" fzf
" Change the split binding to be more mnemonic and match probe.
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit',
  \ }
let g:my_fzf_options = ['--no-mouse', '--scheme=path', $'--history={$HOME}/.fzf/history', '--multi']
" Search in current dir using fzf's internal file listing. Lists everything.
nn <leader>fd :cal fzf#run(fzf#wrap(#{options: g:my_fzf_options}))<cr>
" Search in current dir, using various .ignore files.
nn <leader>z :cal fzf#run(fzf#wrap(#{source: 'rg --files', options: g:my_fzf_options}))<cr>
" Search in repo.
nn <leader>fr :cal fzf#run(fzf#wrap(#{
    \ source: 'rg --files',
    \ options: g:my_fzf_options,
    \ dir: RepoRoot(),
\ }))<cr>
" Search for files in the same dir as the current buffer ("here").
nn <leader>fh :cal fzf#run(fzf#wrap(#{source: 'rg --files', options: g:my_fzf_options, dir: expand('%:h') }))<cr>
" Search listed buffers.
nn <leader>fb :cal fzf#run(fzf#wrap(#{
    \ source: getbufinfo(#{buflisted: 1})->map({_, d -> d['name']}),
    \ options: g:my_fzf_options,
\ }))<cr>


vmap <leader>a <Plug>(EasyAlign)
nmap <leader>a <Plug>(EasyAlign)

let g:NERDTreeDirArrows=0

" Tagbar
nn <leader>t :TagbarOpenAutoClose<cr>
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }

let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : '~/.local/bin/markdown2ctags',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

" vim-go
let g:go_fmt_autosave = 0
let g:go_mod_autosave = 0
let g:go_template_use_pkg = 1

" }}}

" Quickfix {{{

function! JumpToFirstValidError()
    let qflist = getqflist()
    for i in range(len(qflist))
        if qflist[i]['valid'] == v:true
            exe printf(':cc %d', i+1)
            return
        endif
    endfor
endfunction
nn _ :call JumpToFirstValidError()<cr>


function! Make(makeprg)
    call MakeX(#{makeprg: a:makeprg})
endfunction

" MakeX() lets you override compiler options in a single function call,
" allowing for conveniently mapping compilers to different keys.
"
" opts: dict with any subset of {compiler makeprg efm jump=0}
"
" For example to load the "jest" compiler runtime files and pickup the rather
" complicated errorformat but to override makeprg:
"
"     MakeX(#{compiler: 'jest', makeprg: 'yarn jest'})
function! MakeX(opts)
    let makeprg_orig = &l:makeprg
    let errorformat_orig = &l:errorformat
    let previous_compiler = v:none
    if exists("b:current_compiler")
        let previous_compiler = b:current_compiler
    endif

    if a:opts->has_key('compiler')
        exe $"compiler {a:opts['compiler']}"
    endif

    let jump = a:opts->get('jump', 0) ? '' : '!'

    if a:opts->has_key('makeprg')
        let &l:makeprg = a:opts['makeprg']
    endif

    if a:opts->has_key('efm')
        let &l:errorformat = a:opts['efm']
    endif

    try
        exe $'make{jump}'
    finally
        let &l:errorformat = errorformat_orig
        let &l:makeprg = makeprg_orig
        if previous_compiler != v:none
            exe $'compiler {previous_compiler}'
        endif
    endtry
endfunction

" "Make" the current file with the given "compiler".
com! -nargs=* Mf :call Make(<q-args> . ' %:S')
com! -nargs=* Make :call Make(<q-args>)
nn <leader>mm :call Make(&makeprg)<cr>

com! MakeTest call Make('make test')
nn <leader>mu :MakeTest<cr>

com! -nargs=* -complete=file Pyflakes call Make('pyflakes ' . (<q-args> == '' ? '%' : <q-args>))

" Fill the quickfix list with pylint output. Run pylint on all the files
" changed since the last commmit (default) or between given revisions, which
" are passed straight to git diff.
function! PylintGit(...)
    let command = "git diff --name-only " . join(a:000)
    let pathsFromRepoRoot = split(system(command), "\n")
    let prefixLength = strlen(util#trim(system("git rev-parse --show-prefix")))
    let paths = []
    for path in pathsFromRepoRoot
        call add(paths, strpart(path, prefixLength))
    endfor
    let makeprg_orig = &l:makeprg
    let &l:makeprg = "pylint -f parseable -i y -r n " . join(paths, ' ')
    let efm_orig = &l:efm
    let &l:efm = "%f:%l: %m"
    try
        make!
    finally
        let &l:makeprg = makeprg_orig
        let &l:efm = efm_orig
    endtry
endfunction
command! -nargs=* Pg call PylintGit('<args>')

" Set the quickfix list to chunks of changes as shown by git diff.
" Passes its arguments straight to git diff, so by default it diffs the working
" directory with HEAD.
" Sets the first non-empty changed line as the description, if possible.
" Possibly superceded by git-jump.
function! QuickfixGitDiff(...)
    let command = "git diff -U0 " . join(a:000)
    let lines = split(system(command), '\n')
    " Relative paths would be nice but absolute paths are far easier.
    let repoRoot = util#trim(system("git rev-parse --show-toplevel"))
    let file = ''
    let locList = []
    let i = 0
    while i < len(lines)
        let line = lines[i]
        if match(line, '^diff') != -1
            let file = repoRoot .  '/' . matchlist(line, '\v b/(.*)$')[1]
        elseif match(line, '^@@') != -1
            let lineNum = matchlist(line, '\v.* \+(\d*)')[1]
            let descIndex = i + 1
            while len(lines[descIndex]) == 1 && descIndex < len(lines) - 1
                let descIndex += 1
            endwhile
            if match(lines[descIndex], '^diff\|^@@') != -1
                let descIndex = i + 1
            endif
            cal add(locList, {'filename': file, 'lnum': lineNum, 'text': lines[descIndex]})
        endif
        let i += 1
    endwhile
    call setqflist(locList)
endfunction
command! -nargs=* Gdqf call QuickfixGitDiff('<args>')
" }}}

" Git {{{

function! ReadGitDiff()
    0r !git diff
    set filetype=diff
endfunction
command! Gdr call ReadGitDiff()

function! RepoRoot() abort
    let repo_root = system('git rev-parse --show-toplevel')->trim()
    if repo_root =~ '^fatal:'
        throw repo_root
    endif
    return repo_root
endfunction

function! QuickfixConflicts()
    let files = util#trim(system("git status -s | grep '^\\(UU\\|AA\\)' | awk '{print $2}' | tr '\n' ' '"))
    silent! exe printf(":grep '[<]<<<<<<' %s", files)
    redraw!
endfunction
com! -nargs=0 Conflicts call QuickfixConflicts()

" Get the GitHub url for the current location.
function! GitHubUrl() abort
    let dir = shellescape(expand('%:h'))
    let path = shellescape(expand('%'))
    let relpath = system($'git -C {dir} ls-files --full-name {path}')->trim()

    let origin_url = system($'git -C {dir} remote get-url origin')->trim()
    if origin_url =~ 'git@'
        let repo_name = substitute(origin_url, 'git@[^:]*:', '', '')
    elseif origin_url =~ 'http'
        let repo_name = substitute(origin_url, '^https://[^/]*/', '', '')
    endif
    let repo_name = substitute(repo_name, '\.git$', '', '')

    " We might be on a topic branch that hasn't been pushed, so instead use
    " the most recent commit hash that we have from the default branch.
    " Use a hash instead of the branch name to anchor the link in time
    " somewhat.
    let default_branch = system($'git -C {dir} rev-parse --abbrev-ref origin/HEAD')->trim()->split('/')[1]
    let hash = system($'git -C {dir} rev-parse --verify --short {default_branch}')->trim()

    let line = line('.')
    let url = $'https://github.com/{repo_name}/blob/{hash}/{relpath}#L{line}'
    return url
endfunction
command! GitHubUrl cal Clip(Echo(GitHubUrl()))

" }}}

" Evaluation {{{

command -range ExecBash <line1>,<line2>w !bash -s

let g:PipeEvalInterpreter = 'bc'
function! PipeEval(input)
    let result = system(g:PipeEvalInterpreter, a:input . "\n")
    return substitute(result, '\v\n*$', '', 'g')  " Remove trailing newlines.
endfunction
function! PipeEvalOp(type)
    let saved_reg = @"
    let saved_mark = getpos("'x")
    let visual = a:type ==# 'V' || a:type ==# 'v' || a:type ==# "\<c-v>"
    let beg = getpos(visual ? "'<" : "'[")
    let end = getpos(visual ? "'>" : "']")
    let [beg_line, end_line] = [beg[1], end[1]]
    let linewise = beg_line != end_line || a:type ==# 'V' || a:type ==# 'line'

    " Yank input into @".
    if linewise
        silent exe $"{beg_line},{end_line}yank"
    else
        let @" = getregion(beg, end)->join("\n")
    endif

    let @" = PipeEval(@")

    " If the input is linewise, paste the output below; otherwise paste the
    " output inline.
    if linewise
        let @" = "==\n" . @"
        exe $"{end_line}put"
    else
        let @" = ' = ' . @"
        cal setpos("'x", end)
        normal! `xp
    endif

    let @" = saved_reg
    cal setpos("'x", saved_mark)
endfunction
" math eval
nnoremap <leader>em :let g:PipeEvalInterpreter = 'bc'<cr>:set operatorfunc=PipeEvalOp<cr>g@
nnoremap <leader>eM :let g:PipeEvalInterpreter = 'bc'<cr>V:<c-u>call PipeEvalOp(visualmode())<cr>
vnoremap <leader>em :<c-u>let g:PipeEvalInterpreter = 'bc'<cr>:call PipeEvalOp(visualmode())<cr>
" bash eval
nnoremap <leader>eb :let g:PipeEvalInterpreter = 'bash -s'<cr>:set operatorfunc=PipeEvalOp<cr>g@
nnoremap <leader>eB :let g:PipeEvalInterpreter = 'bash -s'<cr>V:<c-u>call PipeEvalOp(visualmode())<cr>
vnoremap <leader>eb :<c-u>let g:PipeEvalInterpreter = 'bash -s'<cr>:call PipeEvalOp(visualmode())<cr>
" python eval
nnoremap <leader>ep :let g:PipeEvalInterpreter = 'python3'<cr>:set operatorfunc=PipeEvalOp<cr>g@
nnoremap <leader>eP :let g:PipeEvalInterpreter = 'python3'<cr>V:<c-u>call PipeEvalOp(visualmode())<cr>
vnoremap <leader>ep :<c-u>let g:PipeEvalInterpreter = 'python3'<cr>:call PipeEvalOp(visualmode())<cr>
" node/javascript eval
nnoremap <leader>ej :let g:PipeEvalInterpreter = 'node -'<cr>:set operatorfunc=PipeEvalOp<cr>g@
nnoremap <leader>eJ :let g:PipeEvalInterpreter = 'node -'<cr>V:<c-u>call PipeEvalOp(visualmode())<cr>
vnoremap <leader>ej :<c-u>let g:PipeEvalInterpreter = 'node -'<cr>:call PipeEvalOp(visualmode())<cr>

function! VimEvalOp(type)
    let saved_reg = @"
    let saved_mark = getpos("'x")
    let visual = a:type ==# 'V' || a:type ==# 'v' || a:type ==# "\<c-v>"
    let beg = getpos(visual ? "'<" : "'[")
    let end = getpos(visual ? "'>" : "']")
    let [beg_line, end_line] = [beg[1], end[1]]
    let linewise = beg_line != end_line || a:type ==# 'V' || a:type ==# 'line'

    " Yank input into @".
    if linewise
        silent exe $"{beg_line},{end_line}yank"
    else
        let @" = getregion(beg, end)->join("\n")
    endif

    " If the input is linewise, paste the output below; otherwise paste the
    " output inline.
    if linewise
        let @" = execute(@")
        let @" = "==\n" . trim(@")
        exe $"{end_line}put"
    else
        let @" = string(eval(trim(@")))
        let @" = ' = ' . @"
        cal setpos("'x", end)
        normal! `xp
    endif

    let @" = saved_reg
    cal setpos("'x", saved_mark)
endfunction
" vim eval
nnoremap <leader>ev :set operatorfunc=VimEvalOp<cr>g@
nnoremap <leader>eV V:<c-u>call VimEvalOp(visualmode())<cr>
vnoremap <leader>ev :<c-u>call VimEvalOp(visualmode())<CR>

" Get the current "selection", either visual or via a mapped operator ('[ and
" ']).
"
" Designed to be called from an operatorfunc. See :h map-operator.
" Can also be called in a normal context to get the current visual selection,
" like `GetSelection(visualmode())`.
function! GetSelection(type) abort
    let visual = a:type ==# 'V' || a:type ==# 'v' || a:type ==# "\<c-v>"
    let beg = getpos(visual ? "'<" : "'[")
    let end = getpos(visual ? "'>" : "']")
    let [beg_line, end_line] = [beg[1], end[1]]
    let linewise = beg_line != end_line || a:type ==# 'V' || a:type ==# 'line'
    return getregion(beg, end, #{type: linewise ? 'V' : 'v'})->join("\n")
endfunction

let g:PipeOpCmd = 'xsel -ib'
let g:PipeOpOut = ''
function! PipeOp(type)
    " Save the output so it can be retrieved via "= if needed.
    let g:PipeOpOut = system(g:PipeOpCmd, GetSelection(a:type))
endfunction

" Copy/paste using xsel, for when clipboard support isn't available or the
" connection to X has been broken.
nnoremap <leader>c :let g:PipeOpCmd = 'xsel -ib'<cr>:set operatorfunc=PipeOp<cr>g@
nnoremap <leader>C :let g:PipeOpCmd = 'xsel -ib'<cr>V:<c-u>call PipeOp(visualmode())<cr>
nnoremap <leader>cc :let g:PipeOpCmd = 'xsel -ib'<cr>V:<c-u>call PipeOp(visualmode())<cr>
" Copy whole file.
nnoremap <leader>% :silent w !xsel -ib<cr>:echo "copied file to clipboard"<cr>
" Copy to end of line, not including the newline.
nnoremap <leader>$ :let g:PipeOpCmd = 'xsel -ib'<cr>vg_:<c-u>call PipeOp(visualmode())<cr>
vnoremap <leader>c :<c-u>let g:PipeOpCmd = 'xsel -ib'<cr>:call PipeOp(visualmode())<cr>
nnoremap <leader>* :call append(line('.'), system('xsel -op')->trim()->split('\n'))<cr>
nnoremap <leader>+ :call append(line('.'), system('xsel -ob')->trim()->split('\n'))<cr>
noremap! <c-r>* <c-r>=trim(system('xsel -op'))<cr>
noremap! <c-r>+ <c-r>=trim(system('xsel -ob'))<cr>

" Display shell command output in a scratch window.
"
" If you have Vim9, consider using `:terminal <cmd>` instead, although that
" won't reuse the same window.
"
" win_mods control window splitting and placement and can be:
"     [vertical] [leftabove|rightbelow|topleft|botright]
function! PipeShellToScratch(buffer_name, cmd, win_mods) abort
    let saved_win = winnr()
    let windows = win_findbuf(bufnr(a:buffer_name))
    if len(windows) > 0
        " Move the cursor to the first window with our buffer name.
        exe win_id2win(windows[0]) . 'wincmd w'
        silent 0,$d  " Clear the window.
    else
        exe printf('%s new', a:win_mods)
        " Set the buffer name.
        exe printf('silent file %s', fnameescape(a:buffer_name))
        setlocal bufhidden=unload " unload buf when no longer displayed
        setlocal buftype=nofile   " buffer is not related to any file
        setlocal nowrap           " don't soft-wrap
        setlocal nobuflisted      " don't show up in the buffer list
    endif
    " pipe in the output from the shell command
    exe printf('silent 0r !%s', a:cmd)
    " Go back to the saved window
    exe saved_win . 'wincmd w'
endfunction
com! -nargs=+ PipeShellToScratch call PipeShellToScratch(<q-args>, <q-mods>)
" }}}

" Vim programming {{{

" Echo and return the given argument.
" Useful for showing an intermediate result.
function! Echo(s)
    echo a:s
    return a:s
endfunction

" }}}

" Misc {{{

" MungeAlone filters a range of lines using a Vim function, similar to
" how :'<,'>!<cmd> would filter lines with a shell command (see :h :range!).
"
" It takes a range of lines, copies them to a new buffer, runs
" the given function in that buffer, and then replaces the range in the
" original buffer with the new buffer's contents.
"
" This is like "narrowing" in Emacs, so you can treat a range as if it was the
" entire file and do things like global search/replace without worrying about
" affecting the rest of the file.
"
" Usage example:
"
"     function! MyMunge(func) abort
"       %s/foo/bar/g
"     endfunction
"     command -range MyMunge silent <line1>,<line2>call MungeAlone({-> MyMunge()})
function! MungeAlone(func) range abort
    let saved_height = winheight(winnr())
    let lines = getline(a:firstline, a:lastline)
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    cal append(0, lines)
    $d  " Delete the empty line that the buffer started with.
    silent call a:func()
    let processed = getline(0, line('$'))
    quit
    exec $'{a:firstline},{a:lastline}d'
    cal append(a:firstline - 1, processed)
    exe $"resize {saved_height}"
endfunction

" Count lines in range. g C-g does something similar.
command! -range -nargs=0 Lines echo <line2> - <line1> + 1 "lines"

function! RedirToTab(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    " use "new" instead of "tabnew" below if you prefer split windows instead of tabs
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
  endif
endfunction
command! -nargs=+ -complete=command RedirToTab call RedirToTab(<q-args>)

function! Chars(start, stop)
    let result = ""
    let i = a:start
    while i < a:stop
        let result .= nr2char(i)
        let i += 1
    endwhile
    return result
endfunction

function! Location()
    return $"{expand('%:p')}:{line('.')}"->substitute('^' . $HOME, '~', '')
endfunction
nn <leader>ml :cal Clip(Location())<cr>
" }}}

" Filetypes {{{

function! GnuC()
  setlocal sw=2 ts=8 et
  setlocal cinoptions=>2s,e-s,n-s,f0,{s,^-s,:s,=s,g0,+.5s,p2s,t0,(0 cindent
endfunction


" The standard markdown plugin is lacking as of Vim7.4
" Improvements in tpope/vim-markdown will eventually be merged upstream.
function! MarkdownLevel()
    let h = matchstr(getline(v:lnum), '^#\+')
    if empty(h)
        return "="
    else
        return ">" . len(h)
    endif
endfunction
" md extension signifies markdown, not modula2
au! filetypedetect BufNewFile,BufRead *.md setlocal filetype=markdown

" gp extension is for gnuplot instead of the PARI/GP calculator.
au! filetypedetect BufNewFile,BufRead *.gp setlocal filetype=gnuplot

" tmac, mom, ms are for groff instead of nroff
au! filetypedetect BufNewFile,BufRead *.tmac,*.mom,*.ms setlocal filetype=groff

" Mandarin Blueprint
au! filetypedetect BufRead,BufNewFile *.mb setlocal filetype=mb


" Group autocommands so they can be easily removed/refreshed.
augroup vimrc
    " Remove all vimrc autocommands.
    autocmd!

    " Indentation settings.
    autocmd Filetype java setlocal sw=2 et
    autocmd Filetype ruby setlocal sw=2 et
    autocmd Filetype lisp filetype indent on
    autocmd Filetype go setlocal sw=4 ts=4 noet
    autocmd Filetype gomod setlocal sw=4 ts=4 noet
    autocmd Filetype c setlocal cindent indentexpr= sw=4 et
    autocmd Filetype cpp setlocal cindent indentexpr= sw=4 et
    autocmd Filetype python setlocal foldmethod=indent foldnestmax=2 foldlevel=99
    au Filetype make setlocal sw=4 ts=4 noet
    au Filetype typescript setlocal sw=2 et
    au Filetype javascript setlocal sw=2 et foldmethod=marker foldmarker={,} foldminlines=5 foldlevel=5

    " Rust
    " Note this block shouldn't be necessary or have any effect in Vim9+
    autocmd Filetype rust let &l:makeprg = 'cargo build'
    autocmd Filetype rust setlocal nosi  " smartindent was being enabled despite filtype indent:OFF

    " Abbreviations
    autocmd FileType java ino <buffer> ;pl System.out.println(
    autocmd FileType rust ino <buffer> ;pl println!(
    autocmd FileType javascript,typescript ino <buffer> ;pl console.log(
    autocmd FileType javascript,typescript ino <buffer> ;pj console.log(JSON.stringify(

    " Markdown
    au FileType markdown setlocal foldexpr=MarkdownLevel()
    au FileType markdown setlocal foldmethod=expr
    " Don't close folds when the filetype is detected.
    au FileType markdown setlocal foldlevel=10
    " Don't worry about underscores within words.
    au Filetype markdown syn clear markdownError
    " Don't hilight italics. I want literal asterisks all the time in my notes
    " and italics don't denote enough emphasis to deserve hilighting anyway.
    au Filetype markdown syn clear markdownItalicDelimiter markdownItalic

    " Powershell: make a new "advanced" function.
    au Filetype ps1 ino ;c {<cr>[CmdletBinding()]<cr>param()<cr>}<esc>ko

    " Groff
    " Add more comment leaders. (These are the most common ones, right?)
    " Don't take roff directives into account for paragraph motions.
    au Filetype groff setlocal comments+=:\\\#,:\\\" paragraphs=


    " Key bindings for filetype-specific stuff.

    autocmd Filetype sh nn <buffer> <leader>my :call Make('shellcheck -f gcc %:S')<cr>
    autocmd Filetype sh no <buffer> <LocalLeader>e :ExecBash<cr>
    autocmd Filetype sh no <buffer> <LocalLeader>E vip:ExecBash<cr>

    autocmd Filetype c nn <buffer> <leader>md :cal DebugVarsC()<cr>

    autocmd Filetype python nn <buffer> <leader>my :call Make('mypy %:S')<cr>
    autocmd Filetype python nn <buffer> <leader>mu :call Make('python3 -munittest %:S')<cr>
    autocmd Filetype python nn <buffer> <leader>md :cal DebugVarsPython()<cr>

    " Rust
    autocmd Filetype rust nn <buffer> <leader>mc :call Make('cargo check --tests')<cr>
    autocmd Filetype rust nn <buffer> <leader>mu :call Make('cargo test')<cr>
    autocmd Filetype rust nn <buffer> <leader>mU :call Make('cargo test --bin ' . expand('%:t:r'))<cr>
    autocmd Filetype rust nn <buffer> <leader>my :call Make('cargo clippy')<cr>
    autocmd Filetype rust nn <buffer> <leader>mY :call Make('./lint')<cr>
    autocmd Filetype rust nn <buffer> <leader>mr :terminal cargo run<cr>
    autocmd Filetype rust nn <buffer> <leader>mR :exe 'terminal cargo run --bin ' . expand('%:t:r')<cr>

    autocmd Filetype java nn <buffer> <leader>mm :call Make('javac %:S')<cr>
    autocmd Filetype java nn <buffer> <leader>mr :exe '!java %'<cr>

    autocmd Filetype groff nn <buffer> <leader>mr :exe '!groff -ww -Tutf8 %'<cr>

    autocmd Filetype javascript nn <buffer> <leader>mb :call CopyAsBookmarklet(0, line('$'))<cr>
    autocmd Filetype javascript vn <buffer> <leader>mb :call CopyAsBookmarklet(line("'<"), line("'>"))<cr>
    autocmd Filetype javascript nn <buffer> <leader>md :cal DebugVarsJavascript()<cr>

    autocmd Filetype javascript nn <buffer> <leader>my :call MakeX(#{makeprg: 'jshint --show-non-errors %:S', efm: '%f: line %l\, col %c\, %m'})<cr>
    autocmd Filetype javascript nn <buffer> <leader>mr :call MakeX(#{compiler: 'javascript', makeprg: 'node %'})<cr>

    autocmd Filetype typescript nn <buffer> <leader>mr :call MakeX(#{compiler: 'tsc', makeprg: 'ts-node %'})<cr>
    autocmd Filetype typescript nn <buffer> <leader>mm :call MakeX(#{compiler: 'tsc', makeprg: filereadable('yarn.lock') ? 'yarn tsc' : 'tsc'})<cr>
    autocmd Filetype typescript nn <buffer> <leader>mu :call MakeX(#{compiler: 'jest', makeprg: (filereadable('yarn.lock') ? 'yarn ' : '') . 'jest 2>&1 \\| tee jest.log'})<cr>
augroup END
" }}}

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif
noh
