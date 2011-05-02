
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Modified by Jordan Torbiak to escape newlines for sending functions to the perl debugger.

function! Send_to_Screen(text)
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    call Screen_Vars()
  end

  if g:screen_mode == "perl"
    " Escape newlines, except for the last one.
    " s/newline/backslash newline/g, then s/last backslash newline/newline/
    let text = substitute(substitute(a:text, "\n", "\\\\\n", "g"), "\\v(\\\\|\s|\n)*$", "", "") . "\n"
  else
    let text = a:text
  end

  echo system("screen -S " . g:screen_sessionname . " -p " . g:screen_windowname . " -X stuff '" . substitute(text, "'", "'\\\\''", 'g') . "'")
endfunction

function! Screen_Session_Names(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function! Screen_Vars()
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    let g:screen_sessionname = ""
    let g:screen_windowname = "0"
  end

  let g:screen_mode = "normal"

  let g:screen_sessionname = input("session name: ", "", "custom,Screen_Session_Names")
  let g:screen_windowname = input("window name: ", g:screen_windowname)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry :call Send_to_Screen(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call Screen_Vars()<CR>
nmap <C-c>m :let g:screen_mode = input("screen mode: ")<CR>

