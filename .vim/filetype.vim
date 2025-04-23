" You need to restart Vim for changes in this file to take effect.
" See `:h new-filetype`
if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    au! BufRead,BufNewFile *.mb setfiletype mb
augroup END
