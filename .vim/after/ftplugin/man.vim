" A regex to find headings and tagged paragraphs / definition lists in long
" man pages, like for awk or bash.
"
" We want to match lines like the following when we type in most of the first
" word:
"
" Simple Commands
" BASH_EXECUTION_STRING
" OPTIONS
" histappend
" blink-matching-paren (Off)
" bind [-m keymap] [-lpsvPSVX]
" -l     List the names of all readline functions.
" read [-ers] [-a aname] [-d delim] [-i text] [-n nchars] [-N nchars] [-p prompt] [-t timeout] [-u fd]
" export -p
" sin(expr)     Return the sine of expr, which is in radians.
"
" ... while not matching that word when it appears in a sentence:
"
" read and executed from the file whose name is the expanded value.  No other startup files are read.
" patterns is evaluated.
"
" So, with a small modification to the regex, the above two blocks of text can
" be used as a test. Note that despite the very-magic flag (\v) being used,
" pipe characters in the regex have to be escaped in the mapping to avoid
" prematurely ending the mapping command.
"
" We're looking for:
" - whitespace
" -  whatever the user types
" - identifier characters til the end of word
" - then one of:
"     - something that looks like a unix syntax description, "export -p", "read [-ers]", etc
"     - a space then a capital letter or hyphen, which probably denote the start of a description
"     - multiple spaces
"     - a function call, like "sin(..."
"     - end of line
"     - a short description or the rest of a heading taking up to about half a line and that that doesn't end in a period. If the search target happens to be in the middle of a paragraph the line will take up the whole window width (>80 chars), and if it's at the end the line will probably end with a period.
"
" The <home> and <right> keys at the end position the cursor inside the first
" capture group, which is where the item to search for is intended to go.

nn <localleader>/ /\v^ *\zs([-_a-zA-Z]*)>\ze( [- \[[A-Z]\|\(\|$\|.{,30}[^.]$)<home><right><right><right><right><right><right><right><right><right>
