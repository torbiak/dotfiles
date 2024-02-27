#!/bin/bash

# Install dotfiles to $HOME.
# The dotfiles repo should be somewhere under $HOME.
# If the repo directory is moved symlinks will need to be recreated.
#
# Since moving to stow, we're using its terminology for "package", "target",
# etc.

set -euo pipefail

# Create symlinks ($HOME -> $DOTFILES_REPO)
stow() {
    inhibit_folding &&
    command stow --dotfiles -t ~/ dotfiles
}

# Delete and remake symlinks, pruning obsolete ones.
restow() {
    # Inhibit folding will usually be unnecessary, but do it in case new
    # nofold_dirs have been added since `stow` was run on this machine.
    inhibit_folding &&
    command stow -R --dotfiles -t ~/ dotfiles
}

inhibit_folding() {
    # Inhibit folding for certain dirs that will also hold aliens.
    local nofold_dirs=(
        ~/.config
        ~/.cmus
    )
    mkdir -p "${nofold_dirs[@]}"
}


delete_preexisting() {
    # Some rm implementations (eg BusyBox) fail when not given any args, so
    # exit early if there's nothing to do.
    (("${#existing[@]}")) || return 0
    local f rc
    rc=0
    for ftgt in "${existing[@]}"; do
        f=$HOME/$ftgt
        if [[ -d "$f" && ! -L "$f" ]]; then
            # Removing dirs from a home directory is scary.
            echo "Refusing to remove directory $f"
            return 1
        fi
        rm "$f" || return 1
    done
    return "$rc"
}

# Backup preexisting dotfiles
backup() {
    (("${#existing[@]}")) || return 0
    backup="$HOME/dotfile_$(date +%FT%T).bak.tar.gz"
    tar -C "$HOME" -czf "$backup" "${existing[@]}"
}

# cp-to-home and cp-to-repo are intended for systems where symlinks are
# unavailable or impractical. Instead of symlinking, the files are copied to
# the home dir. To check what changes have been made to the installed dotfiles,
# use cp-to-repo and run `git diff`. rsync is used since there can be lots of
# files under dotdirs, like plugins under .vim.
cp-to-home() {
    for fpkg in "${dotfiles[@]}"; do
        local trailing="" ftgt
        ftgt=$(p2t "$fpkg")
        [[ -d "$fpkg" ]] && trailing='/'
        rsync -r "dotfiles/$fpkg$trailing" "$HOME/$ftgt"
    done
}

cp-to-repo() {
    if ! git branch > /dev/null; then
        echo "Problem detecting git repo."
        return 1
    fi
    if [[ "$(git status --porcelain)" ]]; then
        echo "Repo has changes. Commit them before continuing."
        return 1
    fi
    for fpkg in "${dotfiles[@]}"; do
        local ftgt
        ftgt=$(p2t "$fpkg")
        if [[ -L "$HOME/$ftgt" ]]; then
            echo "$ftgt is a symlink. Do you really want to copy it to the repo?"
            return 1
        fi
        [[ -e "$HOME/$ftgt" ]] || continue
        local trailing=""
        [[ -d "$HOME/$ftgt" ]] && trailing='/'
        rsync -r "$HOME/$ftgt$trailing" "dotfiles/$fpkg"
    done
}

# Package2Target, eg: dot-vimrc -> .vimrc
p2t() {
    local fpkg=${1:?No file given}; shift
    echo "${fpkg/#dot-/.}"
}

# Target2Package, eg: .vimrc -> dot-vimrc
t2p() {
    local ftgt=${1:?No file given}; shift
    echo "${ftgt/#./dot-}"
}


# Array of dotfiles tracked in the repo.
pushd dotfiles >/dev/null
dotfiles=(*)
popd >/dev/null

# Existing files in $HOME that correspond to dotfiles in the repo.
existing=()
for fpkg in "${dotfiles[@]}"; do
    ftgt=$(p2t "$fpkg")
    [[ -e "$HOME/$ftgt" || -L "$HOME/$ftgt" ]] && existing+=("$ftgt")
done

usage="install stow|restow|cp-to-home|cp-to-repo"
while getopts 'h' opt; do
    case "$opt" in
    h) echo "$usage"; exit 0;;
    *) exit 1;;
    esac
done
shift $((OPTIND-1))
"$@"
