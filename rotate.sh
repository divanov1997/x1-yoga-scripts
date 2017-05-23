#!/bin/bash

# Author : Danil Ivanov
# Find ports on which the acceleromters are connected, this changes at each boot
accel_screen_num=-1
accel_body_num=-1
while read line
do
    # accelerometers are labeled accel_3d-dev<X>, X being the port they're on. That's what 
    # we're after. The first one is usually the screen, the second is the one in the body.
    # Since there's no way to tell which one is which, we assume that the first one is the
    # screen. ${line: -1} gets the last character of $line
    if [[ $line == accel_3d* ]];
    then
        if [[ $accel_screen_num -ge 0 ]]; 
        then
            accel_body_num=${line: -1}
        else
            accel_screen_num=${line: -1}
        fi
    fi
done <<< "$(cat /sys/bus/iio/devices/trigger*/name)"

echo "Found accelerometers on ports" $accel_screen_num "and" $accel_body_num

# We keep track of the current rotation as to not do any unecessary rotations
rotate="none"
while true; do
    accel1_y=$(cat /sys/bus/iio/devices/iio:device$accel_screen_num/in_accel_y_raw)
    accel1_z=$(cat /sys/bus/iio/devices/iio:device$accel_screen_num/in_accel_z_raw)
    
    accel2_y=$(cat /sys/bus/iio/devices/iio:device$accel_body_num/in_accel_y_raw)
    accel2_z=$(cat /sys/bus/iio/devices/iio:device$accel_body_num/in_accel_z_raw)

    # Scale down the angles to be "normal", ie beetween -100 and 100, when they get bigger
    # they just flip.
    accel1_y=$(( accel1_y / 10000 ))
    accel1_z=$(( accel1_z / 10000 ))
    
    accel2_y=$(( accel2_y / 10000 ))
    accel2_z=$(( accel2_z / 10000 ))

    # If the sceen is flipped and the keyboard is facing up, switch to tent mode.
    # When rotating, we flip the wacom input and the screen, and disable the touch 
    # pad, and restore it when flipping back from tent mode 
    if [[ $accel1_y -ge 0 && $accel1_z -le 0 && $accel2_z -le 0 ]];
    then
        if [[ $rotate == "none" ]];
        then
            rotate="half"
            ./wacomrot.sh $rotate
            xrandr --output eDP1 --mode 2048x1152 --rotate inverted
        fi
    else
        if [[ $rotate == "half" ]];
        then
            rotate="none"
            ./wacomrot.sh $rotate
            xrandr --output eDP1 --mode 2048x1152 --rotate normal
        fi
    fi
    sleep 5
done
