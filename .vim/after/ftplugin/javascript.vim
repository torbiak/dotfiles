" The primary purpose of this errorformat is to match syntax errors like
" these:

" file:///home/jtorbiak/exercism/typescript/food-chain/gen_verses.js:57
" );
" ^
"
" SyntaxError: Unexpected token ')'
"     at compileSourceTextModule (node:internal/modules/esm/utils:338:16)
"     at ModuleLoader.moduleStrategy (node:internal/modules/esm/translators:106:18)
"     at #translate (node:internal/modules/esm/loader:473:12)
"     at ModuleLoader.loadAndTranslate (node:internal/modules/esm/loader:520:27)
"     at async ModuleJob._link (node:internal/modules/esm/module_job:115:19)
"
" Node.js v23.8.0

" The order of the patterns matters. Lines that match almost anything should come later.
" The lines between the start (%A) and finish (%Z) need to be matched by (%C) patterns.
let fmt = []
eval fmt->add('%Afile://%f:%l')  " Start by extracting <file>:<line>
eval fmt->add('%C%p^')  " Continue by extracting the column from a 'pointer line' that ends with '^'
" End with a '[a-z]*Error: <message>' line and include the whole line in the error message (%+).
eval fmt->add('%+Z%[a-z]%#Error: %m')
eval fmt->add('%-C%.%#')  " Continue with any (.*) lines, but discard them.
eval fmt->add('%-G%.%#')  " Discard everything else.
let &errorformat = fmt->join(',')
