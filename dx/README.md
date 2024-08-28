dx/ stands for Dotfiles Xtras: scripts and resources that I use on most systems.

With the "bare repo" dotfiles management approach it's awkward to manage the repo, at least initially, since tracked files are mixed in with untracked ones. It seems best to just ignore the untracked files, which is effectively what we were doing before when symlinking to the repo. If we were doing some heavy processing we might clone the repo somewhere else with a contained .git dir, but otherwise we can get by with a few git settings/options/commands that we might not have used so frequently before.

The git command to interact with the dotfiles repo is in ~/dx/bin/dotfiles:

    git --git-dir="$HOME"/dotfiles --work-tree="$HOME"

Ignore untracked files by default:

    dotfiles config --local status.showUntrackedFiles no

Show untracked files normally, mostly for when you you want to see the untracked files in a subdir:

    dotfiles status -unormal

Grep only tracked files:

    dotfiles grep -n <pattern>

List repo files, maybe to give to xargs. The list is limited based on the working dir.

    dotfiles ls-files

Clone to a another system. This is awkward since you'll most likely already have some dotfiles, and thus git will refuse to use `$HOME` as the worktree. So clone the worktree to a temp dir, rsync its contents into `$HOME`, and then the temp dir can be deleted. (git creates an OS-agnostic symlink at tmpdotfiles/.git pointing at ~/.dotfiles, which we want to exclude.)

    git clone --recurse-submodules --separate-git-dir="$HOME/.dotfiles" git@github.com:torbiak/dotfiles tmpdotfiles
    # TODO: if we exclude .git dirs for submodules, does `submodule update --init` recreate them?
    rsync -ril --exclude '.git' ~/tmpdotfiles/ ~/
    rm -rf ~/tmpdotfiles
