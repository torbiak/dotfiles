" ✔ synchronous passing test (0.443214ms)
" ✖ synchronous failing test (1.314092ms)
" ℹ tests 2
" ℹ suites 0
" ℹ pass 1
" ℹ fail 1
" ℹ cancelled 0
" ℹ skipped 0
" ℹ todo 0
" ℹ duration_ms 5.425467
"
" ✖ failing tests:
"
" test at node_test.test.mts:13:1
" ✖ synchronous failing test (1.314092ms)
"   AssertionError [ERR_ASSERTION]: Expected values to be strictly equal:
"
"   1 !== 2
"
"       at TestContext.<anonymous> (file:///home/jtorbiak/code/js/node_test.test.mts:15:10)
"       at Test.runInAsyncScope (node:async_hooks:214:14)
"       at Test.run (node:internal/test_runner/test:1047:25)
"       at Test.processPendingSubtests (node:internal/test_runner/test:744:18)
"       at Test.postRun (node:internal/test_runner/test:1173:19)
"       at Test.run (node:internal/test_runner/test:1101:12)
"       at async startSubtestAfterBootstrap (node:internal/test_runner/harness:297:3) {
"     generatedMessage: true,
"     code: 'ERR_ASSERTION',
"     actual: 1,
"     expected: 2,
"     operator: 'strictEqual'
"   }

let current_compiler = "node-test"

" The order of the patterns matters. Lines that match almost anything should come later.
" The lines between the start (%A) and finish (%Z) need to be matched by (%C) patterns.
let fmt = []
eval fmt->add('%Atest at %f:%l:%c')  " Start by extracting file, line, and character.
eval fmt->add('%-C%. a%\\?synchronous failing test %.%#')  " Discard this line.
eval fmt->add('%Z %#at %.%#')  " Stop at the first stack trace line.
eval fmt->add('%C %#%m')  " Add non-blank lines to the error message.
eval fmt->add('%-G%.%#')  " Discard everything else.
let &l:errorformat = fmt->join(',')
