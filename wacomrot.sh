#!/bin/bash

# Source : https://wiki.archlinux.org/index.php/Wacom_tablet 
device="Wacom Co.,Ltd. Pen and multitouch sensor"
stylus="$device Pen stylus"
eraser="$device Pen eraser"
touch="$device Finger touch"

xsetwacom --set "$stylus" Rotate $1
xsetwacom --set "$eraser" Rotate $1
xsetwacom --set "$touch"  Rotate $1
