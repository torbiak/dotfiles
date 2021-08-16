#!/usr/bin/env bash
# install.sh
# Installs dotfiles to $HOME.
# The dotfiles repo should be somewhere under $HOME.
# If the repo directory is moved this script will need to be run again.
set -eu

# Get relative path from $HOME
pushd "$HOME" 1>/dev/null
# Popd in a subshell, then popd in this shell to get back to the repo dir.
absolute_repo_path=$(popd); popd &> /dev/null
if [[ "$absolute_repo_path" != \~/* ]]; then
    echo 'dotfiles repo should be under $HOME' 1>&2
    exit 1
fi
home_to_repo_dir=${absolute_repo_path#\~/}

# Array of dotfile basenames tracked in the repo.
dotfiles=($(
    cd dotfiles
    ls -d * | sed 's#^#.#'
))

# Print tracked dotfile basenames that already exist in $HOME.
preexisting_dotfiles() {
    for file in "${dotfiles[@]}"; do
        [[ -e "$HOME/$file" ]] || continue
        echo "$file"
    done
}

# Backup preexisting dotfiles
backup() {
    local existing
    existing=($(preexisting_dotfiles))
    (("${#existing[@]}")) || return 0
    backup="$HOME/dotfile_$(date +%FT%T).bak.tar.gz"
    tar -C "$HOME" -czf "$backup" "${existing[@]}"
}

delete_preexisting() {
    local existing
    existing=($(preexisting_dotfiles))
    # Some rm implementations (eg BusyBox) fail when not given any args, so
    # exit early if there's nothing to do.
    (("${#existing[@]}")) || return 0
    rm "${existing[@]/#/$HOME/}" || {
        echo "\
Couldn't delete all pre-existing dotfiles. If there are pre-existing dotdirs,
please remove them manually, since automatically deleting dirs from a home
directory is a dangerous operation to script.

remaining pre-existing dotfiles:
$(preexisting_dotfiles)
" >&2
        return 1
    }
}

# Create symlinks ($HOME -> $DOTFILES_REPO)
symlink() {
    delete_preexisting
    for file in "${dotfiles[@]}"; do
        ln -s "$home_to_repo_dir/dotfiles/${file#.}" "$HOME/$file"
    done
}

# cp-to-home and cp-to-repo are intended for systems where symlinks are
# unavailable or impractical. Instead of symlinking, the files are copied to
# the home dir. To check what changes have been made to the installed dotfiles,
# use cp-to-repo. rsync is used since there can be lots of files under dotdirs,
# like plugins under .vim.
cp-to-home() {
    for file in "${dotfiles[@]}"; do
        local trailing=""
        [[ -d "${file#.}" ]] && trailing='/'
        rsync -r "${file#.}$trailing" "$HOME/$file"
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
        rsync -r $HOME/$file$trailing $(repo-filepath $file)
    done
}

usage="install.sh symlink|cp-to-home|cp-to-repo"
while getopts 'h' opt; do
    case "$opt" in
    h) echo "$usage"; exit 0;;
    esac
done
shift $((OPTIND-1))
"$@"
