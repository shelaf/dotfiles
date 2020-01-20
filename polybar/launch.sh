#!/bin/bash

function launch_bar() {
  MONITOR="${1}" IF_ETHER="${if_eth}" polybar "${2}" &
}

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u "${UID}" -x polybar > /dev/null
do
  sleep 1;
done

if_eth=$(ip link | grep -m 1 -E '\b(en)' | awk '{print substr($2, 1, length($2)-1)}')
IFS=$'\n'
desktop="${1}"

case "${desktop}" in 
  bspwm)
    if command -v xrandr > /dev/null 2>&1; then
      for screen in $(xrandr --query | grep -w connected)
      do
        monitor="${screen%% *}"
        case "${screen}" in 
          *primary*)
            launch_bar "${monitor}" bspwm-top-primary
            launch_bar "${monitor}" bspwm-bottom-primary
            ;;
          *)
            launch_bar "${monitor}" bspwm-top-secondary
            launch_bar "${monitor}" bspwm-bottom-secondary
            ;;
        esac
      done
    else
      launch_bar "" bspwm-top-primary
      launch_bar "" bspwm-bottom-primary
    fi
esac
