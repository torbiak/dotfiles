#!/bin/bash

# Set up dbus and other X session stuff.
# On Arch:
if [[ -d /etc/X11/xinit/xinitrc.d ]]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [[ -x "$f" ]] && . "$f"
    done
    unset f
fi
# On Ubuntu:
#[[ -e /etc/X11/Xsession ]] && . /etc/X11/Xsession

[[ -f ~/.xprofile ]] && . ~/.xprofile  # Put local stuff in here.
[[ -f ~/.keymap.xkb ]] && xkbcomp ~/.keymap.xkb "$DISPLAY" 2>/dev/null
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xrdb -merge ~/.Xresources
[[ -f ~/.xbindkeysrc ]] && xbindkeys
xsetroot -solid black

~/dx/bin/statusbar cont &

exec dwm
