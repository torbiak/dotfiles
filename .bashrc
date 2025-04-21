# Disable warnings about non-constant sources.
# shellcheck shell=bash disable=SC1090

PATH=$HOME/bin:$HOME/dx/bin:$HOME/code/bin:$HOME/.cargo/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH

[[ "$-" == *i* ]] || return

export CLICOLOR=1
export EDITOR=vim
export VISUAL=vim
export HISTFILESIZE=100000
export HISTSIZE=$HISTFILESIZE
export HISTIGNORE="&:[ ]*:exit:l:ll:ls:histdel"
[[ "$LANG" == @(en_US.UTF-8|C|C.UTF-8|POSIX) ]] || export LANG="en_US.UTF-8"
export LC_COLLATE=C  # Using the C locale can speed up some sorting and regex operations.
export LESS="-# 60 -i -X -R"
export LSCOLORS=dxfxcxdxbxegedabagacad
export LS_COLORS='di=1;35:ln=35:ex=31:su=30;43:sg=30;43:tw=30;43:ow=30;43:'
export PAGER=less
export MANOPT='--nh --nj'  # Disable hyphenation and justification.
export PYTHONSTARTUP=$HOME/.pythonrc
export PYTHONPATH=.:$HOME/code/python
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export BC_ENV_ARGS="-l $HOME/.bcrc"
export DISPLAY=:0
export CMUS_HOME=~/.cmus
export GROFF_TMAC_PATH=~/code/groff
HISTTIMEFORMAT='%Y-%m-%dT%H:%M:%S '

case $OSTYPE in
    linux-gnu | cygwin) alias ls='ls --color=auto';;
esac
alias l='ls -F'
alias ll='ls -lh'
alias j='jobs'
alias ocaml='ledit -x -h ~/.ocaml_history ocaml'
alias irssi='TERM=screen-256color irssi'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias dfh='df -hT -x tmpfs -x devtmpfs'
alias ipb='ip -br'
alias sudoh='sudo --preserve-env=HOME'
alias python3='python3 -q'
alias unp='unp -U'
alias feh='feh -.'
alias ncdu='ncdu --color off'

shopt -s histappend checkwinsize cmdhist extglob failglob cdable_vars
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
    shopt -s globstar
fi
set -o histexpand

bind C-p:history-search-backward
bind C-n:history-search-forward
bind '"\C-x\C-k": kill-region'
bind '"\ew": copy-region-as-kill'
bind '"\el": redraw-current-line'
bind '"\em": menu-complete'
bind '"\eM": menu-complete-backward'
# Unbind keys that use \eO as a prefix.
for key in D H F C B A; do
    bind -r '\eO'"$key"
done
bind '"\ep": shell-forward-word'
bind '"\eo": shell-backward-word'
bind '"\eP": shell-kill-word'
bind '"\eO": shell-backward-kill-word'
# Disable revert-all-at-newline for now since there's a long-standing bug in it
# that causes a double-free and crash, usually when the previous command has
# been modified.
bind 'set revert-all-at-newline off'  # Disable persistent history changes.
bind 'set completion-ignore-case on'
bind 'set bell-style none'
bind 'set show-all-if-ambiguous on'
bind 'set enable-bracketed-paste on'
bind 'set colored-stats on'


stty -ixon -ixoff  # Try to disable flow control

case $OSTYPE in
    cygwin|msys|mingw) :;;
    *)
        # increase max file descriptors so file-watching APIs don't run out of them.
        ulimit -S -n 4096
        ulimit -Sm 4000000  # Limit max resident memory to 4GB per process.
    ;;
esac


## Prompt

prompt1() {
    local r="\[\e[31m\]" # red
    local g="\[\e[32m\]" # green
    local y="\[\e[33m\]" # yellow
    local p="\[\e[34m\]" # purple
    local reset="\[\e[0m\]"
    local sep="$y|"
    local status_cmd="\$(s=\$?; [[ \$s -ne 0 ]] && echo \"$r\$s$sep\")"
    local job_cmd="\$([[ \j -ne 0 ]] && echo \"$p\j$sep\")"

    local chroot=
    [[ -v SCHROOT_CHROOT_NAME ]] && chroot="${r}${SCHROOT_CHROOT_NAME}${sep}"

    local git_sub_cmd="gitBranch"
    # Use the prompt function that ships with git if it's available.
    local git_exec_path
    # shellcheck disable=SC1091
    git_exec_path=$(git --exec-path) &&
    [[ -f "$git_exec_path"/git-sh-prompt ]] &&
    . "$git_exec_path"/git-sh-prompt &&
    export GIT_PS1_SHOWDIRTYSTATE=yes &&
    export GIT_PS1_SHOWSTASHSTATE=yes &&
    export GIT_PS1_SHOWUNTRACKEDFILES=yes &&
    export GIT_PS1_SHOWUPSTREAM=auto &&
    export GIT_PS1_STATESEPARATOR='' &&
    git_sub_cmd="__git_ps1 %s"

    local git_cmd="\$(b=\$($git_sub_cmd); [[ -n \"\$b\" ]] && echo \"$sep$g\$b\")"
    PS1="\[\a\]${status_cmd}${job_cmd}${chroot}$g\w${git_cmd}$y\\\$$reset "
}
prompt1

prompt1_cheap() {
    local r="\[\e[31m\]" # red
    local g="\[\e[32m\]" # green
    local y="\[\e[33m\]" # yellow
    local p="\[\e[34m\]" # purple
    local reset="\[\e[0m\]"
    local sep="$y|"
    local status_cmd="\$(s=\$?; [[ \$s -ne 0 ]] && echo \"$r\$s$sep\")"
    local job_cmd="\$([[ \j -ne 0 ]] && echo \"$p\j$sep\")"
    PS1="\[\a\]${status_cmd}${job_cmd}$g\w$y\\\$$reset "
}

# ssh-agent setup.
# Modified version of Joseph Reagle's script from http://mah.everybody.org/docs/ssh
SSH_ENV="$HOME/.ssh/env"
ssh-agent-init() {
    # Don't echo anything, and put assignments on their own line so that the
    # file works as a systemd EnvironmentFile=.
    /usr/bin/ssh-agent | sed -E 's/^echo/#echo/; s/; */\n/g' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" >/dev/null
    /usr/bin/ssh-add
}
# Warn about a stale SSH_ENV on shell start.
if [[ -f "${SSH_ENV}" ]]; then
    . "${SSH_ENV}" >/dev/null
    # ps ${SSH_AGENT_PID} doesn't work under cywgin
    # shellcheck disable=SC2009
    ps -e -o pid,comm | grep -E " *$SSH_AGENT_PID +ssh-agent\$" >/dev/null ||
    echo 'stale ssh-agent env'
fi

sec2hms() {
    local secs=${1:?No seconds given}
    local h m s
    ((h = secs / 3600))
    ((m = (secs % 3600) / 60))
    ((s = secs % 60))
    [[ $h -gt 0 ]] && echo -n "${h}h"
    [[ $m -gt 0 ]] && echo -n "${m}m"
    echo -n "${s}s"
}

# cd to a directory further up your path that contains the given pattern.
# Change to the parent directory if nothing given.
# eg, if pwd is /usr/local/bin, then running "up loc" will cd to /usr/local.
up() {
    if [[ $# -eq 0 ]]; then
        cd ..
        return
    fi
    [[ "$PWD" =~ .*$1[^/]*/ ]] || return 1
    cd "${BASH_REMATCH[0]}" || return 1
}

# Lines2Args: give piped lines as args to the given command.
l2a() {
    xargs -rd '\n' "$@"
}

# Create a new tmux window with the same working directory as the current shell.
# I prefer to think of splitting vertically as using a vertical splitter, as in
# vim and most other tools, not as splitting the vertical space as in tmux, so
# override the tmux terminology.
tmux-split() {
    tmux split-window -v -c "$PWD"
}
alias ts=tmux-split
tmux-vsplit() {
    tmux split-window -h -c "$PWD"
}
alias tv=tmux-vsplit

# Delete last command from history: histdel
# Delete from offset to end of history: histdel OFFSET
# Delete from offset to another offset: histdel OFFSET OFFSET
histdel() {
    local last
    last=$(history | tail -n 1 | awk '{print $1}')
    local start=${1:-$last}
    local end=${2:-$((last+1))}
    while [[ $start -lt $end ]]; do
        history -d "$start"
        end=$((end-1))
    done
}

normal-perms() {
    [[ $# -gt 0 ]] || set .
    find "$@" -type d -exec chmod 755 '{}' \; -o -type f -exec chmod 644 '{}' \;
}

# find files under current directory containing a pattern
ff() {
    pattern=${1:?No pattern given}; shift
    find . -iname "*${pattern}*" "$@" 2>/dev/null
}

# find files ending with a suffix
suf() {
    pattern=${1:?No pattern given}; shift
    find . -iname "*${pattern}" "$@" 2>/dev/null
}


gitBranch() {
    branch_name=$(git symbolic-ref -q HEAD 2>/dev/null || true)
    branch_name=${branch_name##refs/heads/}
    echo "$branch_name"
}

gitTrackingBranch() {
    git rev-parse --symbolic-full-name --abbrev-ref '@{upstream}'
}

# git add rebase continue
garc() {
    git add -u
    git rebase --continue
}

# git submodule update
gsu() {
    local repoRoot
    repoRoot=$(git rev-parse --show-toplevel)
    (cd "$repoRoot" && git submodule update)
}

# git add -p
gap() {
    git add -p "$@"
}

alias gff=git-fixup-fuzzy
git-fixup-fuzzy() {
    # If awk is in the pipeline with fzf then awk will be blocking on read(),
    # so on Ctrl-C it would get EINT from the syscall and exit with 0 instead
    # of receiving a SIGINT, and the entire pipeline would pass, unless we set
    # pipefail so bash considers the pipeline failed due to fzf exiting due to
    # SIGINT.
    local -
    set -o pipefail
    local sha
    sha=$(
        git log --decorate --oneline \
            | fzf --with-nth=2.. --no-sort --preview='git show --stat {+1}' --layout=reverse \
            | awk '{print $1}'
    ) &&
    git commit --fixup="$sha"
}

alias grf=git-rebase-fuzzy
git-rebase-fuzzy() {
    local -
    set -o pipefail
    local sha
    sha=$(
        git log --decorate --oneline \
            | fzf --with-nth=2.. --no-sort --preview='git show --stat {+1}' --layout=reverse \
            | awk '{print $1}'
    ) &&
    git rebase -i "$sha"^
}

most() {
    local usage='most [<options>] [<file>...]

options:
-h          show help
-n <range>  print a range of files (default: 1) (eg: 1,3)
-m          sort by mtime (the default)
-a          sort by atime
-c          sort by ctime
-s          sort by size
-r          reverse order (thus, "least")
-d          only use dirs
-f          only use files'
    local OPTIND=0
    local ls_opts=()
    local n=1 only_dirs only_files
    while getopts ":hn:amcsrdf" opt; do
        case "$opt" in
        h) echo "$usage"; return 0;;
        a) ls_opts+=(-u);;
        m) ;;
        c) ls_opts+=(-c);;
        s) ls_opts+=(-S);;
        r) ls_opts+=(-r);;
        n) n=$OPTARG;;
        d) only_dirs=yes;;
        f) only_files=yes;;
        *) echo "unexpected option: $opt" >&2; return 1;;
        esac
    done
    shift $((OPTIND-1))
    [[ $# -eq 0 ]] && set ./*
    local filtered=()
    if [[ "$only_dirs" ]]; then
        for f in "$@"; do
            [[ -d "$f" ]] && filtered+=("$f")
        done
    elif [[ "$only_files" ]]; then
        for f in "$@"; do
            [[ -f "$f" ]] && filtered+=("$f")
        done
    else
        filtered=("$@")
    fi
    # shellcheck disable=2012
    ls -dt "${ls_opts[@]}" "${filtered[@]}" | sed -n -e "${n}p"
}

cdmost() {
    cd "$(most -d "$@")" || return 1
}


# screen attach
sat() {
    local hostname=${1:-localhost}
    if [[ "$hostname" == localhost ]]; then
        screen -xRR
    else
        ssh -t "$hostname" screen -xRR
    fi
}

# edit binary in PATH
ebin() {
    local path
    path=$(type -p "${1:?binary not given}") || return 1
    "$EDITOR" "$path"
}

# Generate a script to rename/remove a bunch of files.
#
# Edit a list of destinations in an editor, then review the generated script
# before running it. Leave a blank line to remove a file. Don't delete any
# lines, since files are indexed by position.
#
# vidir from moreutils is an alternative to this. qmv from renameutils is less
# appealing due to its "<file><tab><file>" output. I use this quite frequently,
# though, so it's nice to keep edmv around for systems where vidir isn't easily
# available.
edmv() {
    [[ $# -eq 0 ]] && return 0
    local src dst script
    src=$(mktemp --tmpdir edmvsrc.XXXXXXX)
    dst=$(mktemp --tmpdir edmvdst.XXXXXXX)
    script=$(mktemp --tmpdir edmvscript.XXXXXXX)
    echo "set -eu" >"$script"
    for f in "$@"; do echo "$f"; done > "$src"
    cp "$src" "$dst"
    "$EDITOR" "$dst"
    if [[ $(wc -l <"$src") -ne $(wc -l <"$dst") ]]; then
        printf "Line count mismatch between %s and %s\n" "$src" "$dst" 1>&2
        rm "$script"
        return 1;
    fi
    local esc=(sed -e 's/[\$\`\"\\]/\\&/g;')
    while true; do
        read -r a <&3 || break
        read -r b <&4 || break
        if [[ "$b" == "" ]]; then
            printf 'rm "%s"\n' "$(echo "$a" | "${esc[@]}")"
        elif [[ "$a" != "$b" ]]; then
            local simple='^[a-zA-Z_0-9.]*$'
            if [[ "$a" =~ $simple && "$b" =~ $simple ]]; then
                echo "mv $a $b"
            else
                printf 'mv "%s" "%s"\n' "$(echo "$a" | "${esc[@]}")" "$(echo "$b" | "${esc[@]}")"
            fi
        fi
    done 3<"$src" 4<"$dst" >>"$script"
    rm "$src" "$dst"
    "$EDITOR" "$script"
    if "$BASH" "$script"; then
        rm "$script"
    else
        echo "$script exited with $?" >&2
    fi
}

# note commit push
ncp() {
    git commit -am "update from $HOSTNAME" && git push
}

timer() {
    local dur=${1:?No duration given}
    local start left
    start=$(date +%s)
    left=$dur
    while (( left > 0 )); do
        printf "\r%4d" "$left"
        sleep 1
        left=$((start + dur - $(date +%s)))
    done
    # clear line and then echo bell to set urgent flag in window manager
    echo -en '\r\e[2K\a'
}

# Open in BackGround
#
# I want some feedback if the job fails right away, which is probably the most
# common type of failure, so check if the job is still running a short time
# later and print its output if it isn't.
obg() {
    local tmp
    tmp=$(mktemp --tmpdir obg.XXXXXXXX) || return 1

    "$@" &>"$tmp" &

    # Wait a bit in case the job errors out right away.
    sleep 0.1
    if ps -p "$!" &>/dev/null; then
        disown "$!"
    else
        echo "Job already exited. Output:"
        cat "$tmp"
    fi
    rm "$tmp"  # Delete output file, possibly before the job is finished writing to it.
}

sleeptil() {
    local t=${1:?No time given}
    # date supports suprisingly flexible relative and absolute time strings,
    # like +3hour, 'tomorrow 03:00', 2012-09-24T20:02:00, etc.
    next=$(date -d "$t" +%s)
    now=$(date +%s)
    [[ "$next" -le "$now" ]] && return 0
    sleep $((next - now))
}

# Expand stdin or the given files as if they were a heredoc. That is,
# parameter, command, and arithmetic expansions are performed by the shell.
# Also, a backslash must be used to escape any \, $, or ` characters.
heredoc() {
    . <(sed -e '1i cat <<__heredoc_delimiter__' -e '$a __heredoc_delimiter__' "$@")
}

# rg into less, with colors and headings
# Seeing matches grouped by file is nice sometimes.
rgl() {
    rg --color always --heading "$@" | less
}

clipargs() { xsel -ib <<<"$*"; }

# Try to pipe the help/usage of a program to less.
h() {
    # Programs with a `help` subcommand that prints help for the other
    # subcommands.
    if [[ $# -gt 1 && $1 = @(go|pip|git|cargo) ]]; then
        "$1" help "$2" | less
        return
    fi

    # Everything else.
    #
    # Try --help|-h and look at both stdout and stderr, since some programs
    # don't have help options but print help on stderr if an unsupported option
    # is given. Close stdin so programs don't just wait for input.
    # Some interesting cases:
    # - lsof has -h but not --help
    # - lsmod doesn't support --help|-h
    local usage rc
    usage=$("$1" --help 0<&- 2>&1) || usage=$("$1" -h 0<&- 2>&1)
    rc=$?
    [[ "$rc" -eq 127 ]] && echo "$usage" && return 1  # command not found
    [[ -z "$usage" ]] && return 1
    echo "$usage" 0<&- | less
    ((rc != 0)) && echo "$1 exited with $rc" >&2
}

redline() {
    local pattern=${1:?No pattern given}; shift
    awk -v pattern="$pattern" '{
        if (match($0, pattern)) {
            print "\033[31m" $0 "\033[0m"
        } else {
            print $0
        }
    }' "$@"
}

# Set the terminal's background color using the OSC 11 escape sequence,
# supported by many xterm-influenced terminals. Useful for marking a terminal
# as being for a remote machine or for root or something.
bg-color() {
    local raw_color=${1:?No color given}; shift
    local color
    case "$raw_color" in
    \#*) color=$raw_color;;
    r|red) color='#251515';;
    g|green) color='#072824';;
    b|blue) color='#101f2f';;
    black) color='#000000';;
    *) echo "unexpected color: $color" >&2; return 1;;
    esac
    echo -e "\e]11;$color\a"
}

# Run StdIn
#
# Run a script based on the output of a command after opening it for editing.
#
# usage: <pipeline> | rsi
rsi() {
    [[ $# -gt 0 ]] && {
        echo "usage: <pipeline> | rsi"
        return 1
    }
    local script=~/rsi
    # Write stdin to a file, and then redirect the stdio fds to a tty so that
    # $EDITOR can work.
    cat >"$script"
    exec </dev/tty 1>/dev/tty 2>/dev/tty
    "$EDITOR" "$script"
    "$BASH" "$script"
}


dotfiles-begin() {
    export GIT_DIR=~/.dotfiles
    PS1="DOTFILES $PS1"
}
dotfiles-end() {
    unset GIT_DIR
    PS1=${PS1#DOTFILES }
}


[ -e ~/.bash_completion ] && . ~/.bash_completion

[[ -e ~/.fzf/key_bindings.bash ]] && . ~/.fzf/key_bindings.bash
export FZF_DEFAULT_OPTS='-m --no-mouse --exact'

[ -e ~/.bashrc.local ] && . ~/.bashrc.local

dedupe_path() {
    local -A seen
    local paths
    local IFS=$'\n'
    for d in ${PATH//:/$'\n'}; do
        [[ -z "${seen[$d]}" ]] && paths+=("$d")
        seen["$d"]=y
    done
    # Join paths with a colon.
    IFS=:
    set "${paths[@]}"
    PATH="$*"
}
dedupe_path

true
