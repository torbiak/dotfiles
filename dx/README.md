dx/ stands for Dotfiles Xtras: scripts and resources that I use on most systems.

# Cloning

Initial setup is a little awkward since you'll most likely already have some dotfiles, and thus git will refuse to use `$HOME` as the worktree. So clone the worktree to a temp dir, rsync its contents into `$HOME`, and then the temp dir can be deleted. (git creates an OS-agnostic symlink at tmpdotfiles/.git pointing at ~/.dotfiles, which we want to exclude.)

    git clone --recurse-submodules --separate-git-dir="$HOME/.dotfiles" git@github.com:torbiak/dotfiles tmpdotfiles
    # TODO: if we exclude .git dirs for submodules, does `submodule update --init` recreate them?
    rsync -ril --exclude '.git' ~/tmpdotfiles/ ~/
    rm -rf ~/tmpdotfiles

Add ~/dx/bin to PATH to get the dotfiles command, then add an include for the committed git config:

    dotfiles config set include.path dx/gitconfig

# Working with the repo

The git command to interact with the dotfiles repo is in ~/dx/bin/dotfiles:

    git --git-dir="$HOME"/dotfiles --work-tree="$HOME"

And I also use these shell functions to set GIT_DIR and PS1 if I'm going to do much work on my dotfiles repo:

    dotfiles-begin() {
        export GIT_DIR=~/.dotfiles
        PS1="DOTFILES $PS1"
    }
    dotfiles-end() {
        unset GIT_DIR
        PS1=${PS1#DOTFILES }
    }

# Dealing with untracked files

With the "separate git dir" dotfiles management approach you'll most likely have a bunch of untracked files unless you have an incredibly clean home dir. You can either set up an ignore file (~/.gitignore is the global one, so we don't want to use it for our dotfiles repo):

    dotfiles config --local core.excludesFile .gitignore.dotfiles

Or ignore untracked files by default:

    dotfiles config --local status.showUntrackedFiles no

## Commands for working with only tracked files

Show untracked files normally, mostly for when you you want to see the untracked files in a subdir:

    dotfiles status -unormal

Grep only tracked files:

    dotfiles grep -n <pattern>

List repo files, maybe to give to xargs. The list is limited based on the working dir.

    dotfiles ls-files
