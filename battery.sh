#!/bin/bash

# Source : https://bbs.archlinux.org/viewtopic.php?id=138755
BATTINFO=`acpi -b`
    DISPLAY=:0.0 /usr/bin/notify-send "low battery" "$BATTINFO"
if [[ `echo $BATTINFO | grep Discharging` && `echo $BATTINFO | sed 's/.*[ \t][ \t]*\([0-9][0-9]*\)%.*/\1/' < 60 ]] ; then
    DISPLAY=:0.0 /usr/bin/notify-send "low battery" "$BATTINFO"
fi

# command to get battery percentage acpi | sed 's/.*[ \t][ \t]*\([0-9][0-9]*\)%.*/\1/'
