filetype off 
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

set laststatus=2
set sts=4 ts=4 sw=4 et
set ai si
set ic hls
set ruler

map Y y$

set guioptions='cM'
colorscheme koehler

cnoremap <C-A>		<Home>
cnoremap <C-B>		<Left>
cnoremap <C-D>		<Del>
cnoremap <C-E>		<End>
cnoremap <C-F>		<Right>
cnoremap <C-N>		<Down>
cnoremap <C-P>		<Up>
cnoremap <Esc><C-B>	<S-Left>
cnoremap <Esc><C-F>	<S-Right>

syntax enable

function! SilentMake(...)
    if a:0 >= 1
        execute "silent! make! " . a:1
    else
        silent! make!
    endif
    redraw!
endfunction
com! -nargs=? Ma call SilentMake(<f-args>)

