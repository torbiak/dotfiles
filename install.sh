#!/bin/bash

# Installs dotfiles to $HOME.
# The dotfiles repo should be somewhere under $HOME.
# If the repo directory is moved this script will need to be run again.

set -euo pipefail

# Create symlinks ($HOME -> $DOTFILES_REPO)
symlink() {
    delete_preexisting || return 1
    for file in "${dotfiles[@]}"; do
        ln -s "$home_to_repo_dir/dotfiles/${file#.}" "$HOME/$file" || return 1
    done
}

delete_preexisting() {
    # Some rm implementations (eg BusyBox) fail when not given any args, so
    # exit early if there's nothing to do.
    (("${#existing[@]}")) || return 0
    local f rc
    rc=0
    for f in "${existing[@]}"; do
        f=$HOME/$f
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
    for file in "${dotfiles[@]}"; do
        local trailing=""
        [[ -d "${file#.}" ]] && trailing='/'
        rsync -r "dotfiles/${file#.}$trailing" "$HOME/$file"
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
    for file in "${dotfiles[@]}"; do
        if [[ -L "$HOME/$file" ]]; then
            echo "$file is a symlink. Do you really want to copy it to the repo?"
            return 1
        fi
        [[ -e "$HOME/$file" ]] || continue
        local trailing=""
        [[ -d "$HOME/$file" ]] && trailing='/'
        rsync -r "$HOME/$file$trailing" "dotfiles/${file#.}"
    done
}

special() {
    install_cmusrc ||
    return 1
}

install_cmusrc() {
    local cmus_config=~/.cmus
    mkdir -p "$cmus_config" &&
    ln -s "$abs_repo_path/dotfiles_special/cmusrc" "$cmus_config/rc"
}


abs_repo_path=$(cd "${BASH_SOURCE%/*}"; pwd)
if [[ "$abs_repo_path" != $HOME* ]]; then
    # shellcheck disable=SC2016
    echo 'dotfiles repo should be under $HOME' 1>&2
    exit 1
fi
home_to_repo_dir=${abs_repo_path#$HOME/}

# Array of dotfile basenames tracked in the repo.
dotfiles=()
for f in dotfiles/*; do
    dotfiles+=(."${f#*/}")
done

# dotfile basenames that already exist in $HOME.
existing=()
for file in "${dotfiles[@]}"; do
    [[ -e "$HOME/$file" || -L "$HOME/$file" ]] && existing+=("$file")
done

usage="install.sh symlink|cp-to-home|cp-to-repo|special"
while getopts 'h' opt; do
    case "$opt" in
    h) echo "$usage"; exit 0;;
    *) exit 1;;
    esac
done
shift $((OPTIND-1))
"$@"
