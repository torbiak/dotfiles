#!/bin/bash

# Important for setting up dbus.
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [[ -x "$f" ]] && . "$f"
    done
    unset f
fi

[[ -f ~/.xprofile ]] && . ~/.xprofile
[[ -f ~/.keymap.xkb ]] && xkbcomp ~/.keymap.xkb "$DISPLAY" 2>/dev/null
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xrdb -merge ~/.Xresources
[[ -f ~/.xbindkeysrc ]] && xbindkeys
xsetroot -solid black

~/dx/bin/statusbar cont &

exec dwm
