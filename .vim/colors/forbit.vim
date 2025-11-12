" Name:         forbit
" Description:  Designed to be used with 4-bit terminal colors and a dark background. Tries to save emphasis like red, bold, and non-default background colors for when it really matters.
" Author:       Jordan Torbiak <torbiak@gmail.com>
" Maintainer:   Jordan Torbiak <torbiak@gmail.com>
" Website:      https://torbiak.com
" License:      Public domain
" Last Updated: Tue 06 Feb 2024 03:46:21 PM MST

hi clear
let g:colors_name = 'forbit'

if &background == 'dark'
    hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE
    hi Comment ctermfg=lightblue ctermbg=NONE cterm=NONE
    hi Constant ctermfg=darkmagenta ctermbg=NONE cterm=NONE
    hi Identifier ctermfg=darkcyan ctermbg=NONE cterm=NONE
    hi Function ctermfg=lightcyan ctermbg=NONE cterm=NONE
    hi Statement ctermfg=darkyellow ctermbg=NONE cterm=NONE
    hi PreProc ctermfg=lightyellow ctermbg=NONE cterm=NONE
    hi PreCondit ctermfg=lightred ctermbg=NONE cterm=NONE
    hi Type ctermfg=darkgreen ctermbg=NONE cterm=NONE
    hi Special ctermfg=lightblue ctermbg=NONE cterm=NONE
    hi Underlined ctermfg=lightblue ctermbg=NONE cterm=underline
    hi Ignore ctermfg=black ctermbg=black cterm=NONE
    hi Error ctermfg=black ctermbg=lightred cterm=NONE
    hi Todo ctermfg=black ctermbg=darkyellow cterm=NONE
    hi Conceal ctermfg=lightgrey ctermbg=lightgrey cterm=NONE
    hi Cursor ctermfg=black ctermbg=white cterm=NONE
    hi lCursor ctermfg=black ctermbg=white cterm=NONE
    hi CursorIM ctermfg=NONE ctermbg=NONE cterm=NONE
    hi Title ctermfg=darkmagenta ctermbg=NONE cterm=NONE
    hi Directory ctermfg=darkgreen ctermbg=NONE cterm=NONE
    hi Search ctermfg=black ctermbg=darkgreen cterm=NONE
    hi IncSearch ctermfg=black ctermbg=lightyellow cterm=bold
    hi NonText ctermfg=lightblue ctermbg=NONE cterm=bold
    hi EndOfBuffer ctermfg=lightblue ctermbg=NONE cterm=NONE
    hi ErrorMsg ctermfg=white ctermbg=darkred cterm=NONE
    hi WarningMsg ctermfg=darkred ctermbg=NONE cterm=NONE
    hi SignColumn ctermfg=lightcyan ctermbg=black cterm=NONE
    hi ColorColumn ctermfg=white ctermbg=darkgrey cterm=NONE
    hi FoldColumn ctermfg=NONE ctermbg=black cterm=NONE
    hi Folded ctermfg=darkblue ctermbg=NONE cterm=bold
    hi CursorColumn ctermfg=NONE ctermbg=NONE cterm=underline
    hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline
    hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=underline
    hi Visual ctermfg=black ctermbg=darkcyan cterm=NONE
    hi VisualNOS ctermfg=NONE ctermbg=black cterm=underline
    hi LineNr ctermfg=darkgrey ctermbg=NONE cterm=NONE
    hi! link LineNrAbove LineNr
    hi! link LineNrBelow LineNr
    hi MatchParen ctermfg=white ctermbg=darkgrey cterm=NONE
    hi ModeMsg ctermfg=NONE ctermbg=NONE cterm=bold
    hi MoreMsg ctermfg=lightblue ctermbg=NONE cterm=bold
    hi Question ctermfg=lightgreen ctermbg=NONE cterm=bold
    hi SpecialKey ctermfg=darkblue ctermbg=NONE cterm=NONE
    hi WildMenu ctermfg=black ctermbg=darkyellow cterm=NONE
    hi QuickFixLine ctermfg=black ctermbg=darkcyan cterm=NONE
    hi SpellBad ctermfg=darkred ctermbg=NONE cterm=underline
    hi SpellCap ctermfg=darkblue ctermbg=NONE cterm=underline
    hi SpellLocal ctermfg=darkmagenta ctermbg=NONE cterm=underline
    hi SpellRare ctermfg=darkyellow ctermbg=NONE cterm=underline
    hi StatusLine ctermfg=NONE ctermbg=darkblue cterm=NONE
    hi StatusLineNC ctermfg=black ctermbg=white cterm=NONE
    hi StatusLineTerm ctermfg=lightgreen ctermbg=darkgrey cterm=bold
    hi StatusLineTermNC ctermfg=darkgreen ctermbg=darkgrey cterm=NONE
    hi VertSplit ctermfg=black ctermbg=white cterm=NONE
    hi TabLine ctermfg=white ctermbg=darkgrey cterm=NONE
    hi TabLineFill ctermfg=NONE ctermbg=black cterm=reverse
    hi TabLineSel ctermfg=white ctermbg=black cterm=bold
    hi ToolbarLine ctermfg=NONE ctermbg=black cterm=NONE
    hi ToolbarButton ctermfg=black ctermbg=lightgrey cterm=bold
    hi Pmenu ctermfg=NONE ctermbg=darkgrey cterm=NONE
    hi PmenuSbar ctermfg=NONE ctermbg=NONE cterm=NONE
    hi PmenuSel ctermfg=black ctermbg=lightgrey cterm=NONE
    hi PmenuThumb ctermfg=NONE ctermbg=white cterm=NONE
    hi DiffAdd ctermfg=DarkGreen ctermbg=Black cterm=NONE
    hi DiffChange ctermfg=DarkYellow ctermbg=Black cterm=NONE
    hi DiffDelete ctermfg=DarkRed ctermbg=Black cterm=NONE
    hi DiffText ctermfg=Black ctermbg=DarkYellow cterm=bold
else
    hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE
    hi Comment ctermfg=darkblue ctermbg=NONE cterm=NONE
    hi Constant ctermfg=darkmagenta ctermbg=NONE cterm=NONE
    hi Identifier ctermfg=darkcyan ctermbg=NONE cterm=NONE
    hi Function ctermfg=darkcyan ctermbg=NONE cterm=NONE
    hi Statement ctermfg=darkyellow ctermbg=NONE cterm=NONE
    hi PreProc ctermfg=darkyellow ctermbg=NONE cterm=NONE
    hi PreCondit ctermfg=darkred ctermbg=NONE cterm=NONE
    hi Type ctermfg=darkgreen ctermbg=NONE cterm=NONE
    hi Special ctermfg=darkblue ctermbg=NONE cterm=NONE
    hi Underlined ctermfg=darkblue ctermbg=NONE cterm=underline
    hi Ignore ctermfg=black ctermbg=black cterm=NONE
    hi Error ctermfg=black ctermbg=darkred cterm=NONE
    hi Todo ctermfg=black ctermbg=darkyellow cterm=NONE
    hi Conceal ctermfg=darkgrey ctermbg=darkgrey cterm=NONE
    hi Cursor ctermfg=black ctermbg=white cterm=NONE
    hi lCursor ctermfg=black ctermbg=white cterm=NONE
    hi CursorIM ctermfg=NONE ctermbg=NONE cterm=NONE
    hi Title ctermfg=darkmagenta ctermbg=NONE cterm=NONE
    hi Directory ctermfg=darkgreen ctermbg=NONE cterm=NONE
    hi Search ctermfg=white ctermbg=blue cterm=bold
    hi IncSearch ctermfg=white ctermbg=red cterm=bold
    hi NonText ctermfg=darkblue ctermbg=NONE cterm=bold
    hi EndOfBuffer ctermfg=darkblue ctermbg=NONE cterm=NONE
    hi ErrorMsg ctermfg=white ctermbg=darkred cterm=NONE
    hi WarningMsg ctermfg=darkred ctermbg=NONE cterm=NONE
    hi SignColumn ctermfg=darkcyan ctermbg=grey cterm=NONE
    hi ColorColumn ctermfg=NONE ctermbg=white cterm=NONE
    hi FoldColumn ctermfg=NONE ctermbg=grey cterm=NONE
    hi Folded ctermfg=darkblue ctermbg=NONE cterm=bold
    hi CursorColumn ctermfg=grey ctermbg=darkyellow cterm=NONE
    hi CursorLine ctermfg=grey ctermbg=darkyellow cterm=NONE
    hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=underline
    hi Visual ctermfg=black ctermbg=yellow cterm=NONE
    hi VisualNOS ctermfg=NONE ctermbg=black cterm=underline
    hi LineNr ctermfg=darkgrey ctermbg=NONE cterm=NONE
    hi! link LineNrAbove LineNr
    hi! link LineNrBelow LineNr
    hi MatchParen ctermfg=cyan ctermbg=NONE cterm=bold
    hi ModeMsg ctermfg=NONE ctermbg=NONE cterm=bold
    hi MoreMsg ctermfg=darkblue ctermbg=NONE cterm=bold
    hi Question ctermfg=darkgreen ctermbg=NONE cterm=bold
    hi SpecialKey ctermfg=darkblue ctermbg=NONE cterm=NONE
    hi WildMenu ctermfg=black ctermbg=darkyellow cterm=NONE
    hi QuickFixLine ctermfg=black ctermbg=darkcyan cterm=NONE
    hi SpellBad ctermfg=darkred ctermbg=NONE cterm=underline
    hi SpellCap ctermfg=darkblue ctermbg=NONE cterm=underline
    hi SpellLocal ctermfg=darkmagenta ctermbg=NONE cterm=underline
    hi SpellRare ctermfg=darkyellow ctermbg=NONE cterm=underline
    hi StatusLine ctermfg=white ctermbg=green cterm=bold
    hi StatusLineNC ctermfg=grey ctermbg=darkgreen cterm=NONE
    hi StatusLineTerm ctermfg=white ctermbg=darkgreen cterm=bold
    hi StatusLineTermNC ctermfg=grey ctermbg=darkgreen cterm=NONE
    hi VertSplit ctermfg=darkgreen ctermbg=darkgreen cterm=NONE
    hi TabLine ctermfg=grey ctermbg=darkyellow cterm=NONE
    hi TabLineFill ctermfg=NONE ctermbg=darkyellow cterm=NONE
    hi TabLineSel ctermfg=white ctermbg=darkyellow cterm=bold
    hi ToolbarLine ctermfg=NONE ctermbg=black cterm=NONE
    hi ToolbarButton ctermfg=black ctermbg=darkgrey cterm=bold
    hi Pmenu ctermfg=black ctermbg=white cterm=NONE
    hi PmenuSbar ctermfg=black ctermbg=white cterm=NONE
    hi PmenuSel ctermfg=white ctermbg=black cterm=NONE
    hi PmenuThumb ctermfg=black ctermbg=white cterm=NONE
    hi DiffAdd ctermfg=darkgreen ctermbg=grey cterm=NONE
    hi DiffChange ctermfg=darkgrey ctermbg=grey cterm=NONE
    hi DiffDelete ctermfg=darkred ctermbg=NONE cterm=NONE
    hi DiffText ctermfg=darkblue ctermbg=grey cterm=bold
endif
