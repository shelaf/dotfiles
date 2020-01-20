#!/bin/bash

userresources=${HOME}/.Xresources
usermodmap=${HOME}/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f ${sysresources} ]; then
  xrdb -merge ${sysresources}
fi

if [ -f ${sysmodmap} ]; then
  xmodmap ${sysmodmap}
fi

if [ -f "${userresources}" ]; then
  xrdb -merge "$userresources"
fi

if [ -f "${usermodmap}" ]; then
    xmodmap "${usermodmap}"
fi


if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "${f}" ] && . "${f}"
 done
 unset f
fi

[ -f ~/.xprofile ] && . ~/.xprofile

session=${1:-bspwm}
dbus_args=(--sh-syntax --exit-with-session)

case "${session}" in
  bspwm)
    dbus_args+=(bspwm) ;;
  i3|i3wm)
    dbus_args+=(i3 --shmlog-size 0) ;;
  xmonad)
    dbus_args+=(xmonad) ;;
  *)
    dbus_args+=("${1}") ;;
esac

xrandr --dpi 120 &
exec dbus-launch "${dbus_args[@]}"
