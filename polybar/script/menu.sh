#!/bin/bash

Y_OFFSET=2  # vertical position in lines
MAX_LINES=20
DISABLE_CAT_INPUTLINE="#mainbox {children: [ listview ];}"  # unset it to have input line on categories
# DISABLE_CAT_INPUTLINE=""

THEME="  #window {
    location: northwest;
    anchor: northwest;
    y-offset: ${Y_OFFSET}em;}
  #listview {
    fixed-height: false;
    lines: $MAX_LINES;
    dynamic: true;}"
ALL_CAT=" Applications"
TITLE="Menu:"

# new line separated list
desired='Favorites
Settings
Development 
Documentation
Education
System
Network
Utility
Graphics
Office
AudioVideo
Accessories
Multimedia
Internet'

present=$(grep Categories /usr/share/applications/*.desktop \
  | cut -d'=' -f2 \
  | sed 's/;/\n/g' \
  | LC_COLLATE=POSIX sort --ignore-case --unique \
  | grep "$desired" -F -x - \
  | sed -e 's/Settings/ Settings/g' -e 's/Development/ Development/g' -e 's/AudioVideo/ AudioVideo/g' -e 's/Documentation/ Documentation/g' -e 's/Office/ Office/g' -e 's/System/漣 System/g' -e 's/Utility/ Utility/g' -e 's/Accessories/ Accessories/g' -e 's/Multimedia/ Multimedia/g' -e 's/Education/拾 Education/g' -e 's/Internet/ Internet/g' -e 's/Graphics/ Graphics/g' -e 's/Network/ Network/g')

menulist=" Terminal
 Filemanager
 Browser
$ALL_CAT
$present
 Search"

# determine max category name length

set -- $menulist
maxlength=1
while [ $# -gt 0 ] ; do
  if [ ${#1} -gt $maxlength ] ; then
    maxlength=${#1}
  fi
  shift
done
 
maxlength=$(($maxlength+8))
#maxlength=18
while true; do
  category=$(echo "$menulist" \
    | rofi -show-icons -dpi 120 -dmenu \
      -i \
      -no-custom \
      -config "~/.config/rofi/config-monocle.rasi" \
      -select "$category" \
      -p "$TITLE" \
      -theme-str "$THEME
        #window {
          width: ${maxlength}ch;
          x-offset: 0;}
          $DISABLE_CAT_INPUTLINE" \
    | awk '{print $2}')

  if [ -z "$category" ] ; then
    exit
  fi

  # determine vertical position of submenu
  yoffset=$Y_OFFSET
  set -- $menulist
  while [ "$category" != "$1" ] ; do
    yoffset=$(($yoffset+1))
    shift
  done
    yoffset=$(($yoffset/2+1))
  
  if [ "$category" = "$ALL_CAT" ] ; then
    category=""
  elif [ "$category" = "Terminal" ] ; then
    exec default-terminal &
    exit
  elif [ "$category" = "Browser" ] ; then
    exec default-browser &
    exit
  elif [ "$category" = "Filemanager" ] ; then
    xdg-open ~ &
    exit
  elif [ "$category" = "Search" ] ; then
    rofi-finder.sh &
    exit
  fi

  sleep 0.15  # pause to avoid instant menu closing with mouse
  
  command=$(rofi -show-icons -dpi 120 -modi drun \
      -show drun \
      -drun-match-fields categories,name \
      -run-command "echo {cmd}" \
      -filter "$category " \
      -no-sidebar-mode \
      -config "~/.config/rofi/config-monocle.rasi" \
      -theme-str "$THEME
        #window {
          width: 40ch;
          x-offset: ${maxlength}ch;
          y-offset: ${yoffset}em;}")

  if [ -n "$command" ] ; then
    eval "$command" &
    exit
  fi
done
