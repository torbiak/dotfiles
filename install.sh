#!/usr/bin/env bash
# install.sh
# Installs symlinks in $HOME to point to the dotfiles in the repo.
# The dotfiles repo should be somewhere under $HOME.
# If the repo directory is moved this script will need to be run again.
# Old dotfiles are saved in a tarball in $HOME.
set -eu

# Get relative path from $HOME
pushd $HOME 1>/dev/null
# Popd in a subshell, then popd in this shell to get back to the repo dir.
absolute_repo_path=$(popd); popd &> /dev/null
if [[ "$absolute_repo_path" != \~/* ]]; then
    echo 'dotfiles repo should be under $HOME' 1>&2
    exit
fi
home_to_repo_dir=${absolute_repo_path#\~/}

# List of dotfiles tracked in the repo.
dotfiles=$(
    for path in dotfiles/*; do
        f=$(basename $path)
        echo ".$f"
    done
)

# List of tracked dotfiles that already exist in $HOME
preexisting_dotfiles=$(
    for file in $dotfiles; do
        if [[ -e $HOME/$file ]]; then
            echo $file
        fi
    done
)

# Convert dotfile filename to repo filepath.
# eg: .vimrc -> dotfiles/vimrc
function repo-filepath {
    echo dotfiles/${file#.}
}

# Backup preexisting dotfiles
function backup {
  if [[ -n "$preexisting_dotfiles" ]]; then
      backup="$HOME/dotfile_$(date +%FT%T).bak.tar.gz"
      tar -C $HOME -czf $backup $preexisting_dotfiles
  fi
}

# Delete preexisting tracked dotfiles.
function delete {
  for file in $preexisting_dotfiles; do
      rm -rf $HOME/$file
  done
}

# Create symlinks ($HOME -> $DOTFILES_REPO)
function symlink {
    delete
    for file in $dotfiles; do
        ln -s "$home_to_repo_dir/dotfiles/${file#.}" $HOME/$file
    done
}

function cp-to-home {
    for file in $dotfiles; do
        local trailing=""
        [[ -d $(repo-filepath $file) ]] && trailing='/'
        rsync -r $(repo-filepath $file)$trailing $HOME/$file
    done
}

function cp-to-repo {
    if ! git branch > /dev/null; then
        echo "Problem detecting git repo."
        return 1
    fi
    if [[ $(git status --porcelain) ]]; then
        echo "Repo has changes. Commit them before continuing."
        return 1
    fi
    for file in $dotfiles; do
        if [[ -L $HOME/$file ]]; then
            echo "$file is a symlink. Do you really want to copy it to the repo?"
            return 1
        fi
        [[ -e $HOME/$file ]] || continue
        local trailing=""
        [[ -d $HOME/$file ]] && trailing='/'
        rsync -r $HOME/$file$trailing $(repo-filepath $file)
    done
}

cmd=${1:?No command given}
$cmd
