if did_filetype()
    finish
endif
if getline(1) =~# '^#!.*smash$'
    setfiletype sh
endif
