export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/soylatte16-i386-1.0.3/bin/:$PATH
export MANPATH=/opt/local/share/man:$MANPATH
export PYTHONPATH=/usr/local/lib/python2.5/site-packages:/Library/Python/2.5/site-packages

export CLICOLOR=1
export LSCOLORS=dxfxcxdxbxegedabagacad

export HISTFILESIZE=10000
export HISTSIZE=10000
export PATH=$PATH:~/bin
export EDITOR=vim
export VISUAL=vim
export LESS="-# 60 -i -r"
export PAGER=less

shopt -s histappend checkwinsize cmdhist extglob
set show-all-if-ambiguous on



function prompt1() {
    local white="\[\e[37;40m\]"
    local yellow="\[\e[33;40m\]"
    local green="\[\e[32;40m\]"
    local orig="\[\e[0m\]"
    PS1="$green($yellow\$?$green)$yellow\$(date +%H:%M)$green:$yellow\w$green\$$orig "
}
prompt1

alias l='ls'
alias ll='ls -l'
alias j='jobs'
alias screen='screen -h 10000'
alias ocaml='ledit -x -h ~/.ocaml_history ocaml'

bind "\C-p":history-search-backward
bind "\C-n":history-search-forward

up() {
  if [[ "$1" != "" ]]; then
    cd $(echo "$PWD" | perl -pe "s#(.*$1[^/]*/).*#\1#i;")
  else
    cd ..
  fi
}
