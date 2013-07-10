" =============================================================================
" File:          autoload/ctrlp/tc.vim
" Description:   Example extension for ctrlp.vim
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['tc']
"
" Where 'tc' is the name of the file 'tc.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]

" Get the script's filename, in this example s:n is 'tc'
let s:n = exists('s:n') ? s:n : fnamemodify(expand('<sfile>', 1), ':t:r')

" Load guard
if ( exists('g:loaded_ctrlp_'.s:n) && g:loaded_ctrlp_{s:n} )
    \ || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_{s:n} = 1


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp#'.s:n.'#init()',
    \ 'accept': 'ctrlp#'.s:n.'#accept',
    \ 'lname': 'testcase',
    \ 'sname': 'tc',
    \ 'type': 'line',
    \ 'sort': 0,
    \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#{s:n}#init()
    return ctrlp#{s:n}#get_tcs()
endfunction

" Trim leading and trailing whitespace (including newlines) from a string.
function! s:trim(s)
    return substitute(a:s, '\v^(\s|\n)*|(\s|\n)*$', '', 'g')
endfunction

let s:cached_tcs = []
function! ctrlp#{s:n}#get_tcs()
    let repoRoot = s:trim(system("git rev-parse --show-toplevel"))
    let searchDirs = printf('%s/yycli/testcases', repoRoot)
    if empty(s:cached_tcs)
        let s:cached_tcs = split(system("find -L " . searchDirs . " -name \"*.py\" | xargs awk '/QC_ID = / { print $3 \":\" ARGV[ARGIND]}'"))
    endif
    return s:cached_tcs
endfunction

function! ctrlp#{s:n}#clear_cache()
    let s:cached_tcs = []
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#{s:n}#accept(mode, str)
    let fname = join(split(a:str, ':')[1:]) " Strip QC_ID
    ctrlp#acceptfile(a:mode, fname)
endfunction

" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#{s:n}#id()
    return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/tc.vim
" command! CtrlPTc call ctrlp#init(ctrlp#tc#id())
