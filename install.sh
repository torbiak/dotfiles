#!/usr/bin/env bash
# install.sh
# Installs symlinks in $HOME to point to the dotfiles in the repo.
# The dotfiles repo should be somewhere under $HOME.
# If the repo directory is moved this script will need to be run again.
# Old dotfiles are saved in a tarball in $HOME.
set -eu

# List of dotfiles and dotfolders to create symlinks to in $HOME.
dotfiles=$(cat <<EOF
.bashrc
.bash_profile
.gitconfig
.hgrc
.inputrc
.perlrc
.screenrc
.vim
.vimrc
EOF
)

preexisting_dotfiles=$(
    for file in $dotfiles; do
    	if [[ -e $HOME/$file ]]; then
    		echo $file
    	fi
    done
)

# Backup preexisting dotfiles
if [[ -n "$preexisting_dotfiles" ]]; then
	backup="$HOME/dotfile_$(date +%FT%T).bak.tar.gz"
	tar -C $HOME -czf $backup $preexisting_dotfiles
fi

# Get relative path from $HOME
pushd $HOME 1>/dev/null
absolute_repo_path=$(popd)
if [[ "$absolute_repo_path" != \~/* ]]; then
    echo 'dotfiles repo should be under $HOME' 1>&2
    exit
fi
home_to_repo_dir=${absolute_repo_path#\~/}

# Create symlinks
for file in $dotfiles; do
    if [[ -f $HOME/$file || -L $HOME/$file ]]; then
    	rm $HOME/$file
    elif [[ -d $HOME/$file ]]; then
        rm -rf $HOME/$file
    fi
    ln -s "$home_to_repo_dir/dotfiles/${file#.}" $HOME/$file
done
