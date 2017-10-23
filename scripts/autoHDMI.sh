#!/bin/bash

# setting up new mode for my HDMI
xrandr --newmode "1920x1080_60.00" 85.25 1368 1440 1576 1784 768 771 781 798 -hsync +vsync
xrandr --addmode HDMI1 1920x1080_60.00


# default monitor is LVDS1
MONITOR=LVDS1

# functions to switch from LVDS1 to HDMI and vice versa
function ActivateHDMI {
    echo "Switching to HDMI1"
    xrandr --output HDMI1 --auto --right-of LVDS1 &
    $HOME/scripts/random-wall.sh --reload
    MONITOR=HDMI1
}
function DeactivateHDMI {
    echo "Switching to LVDS1"
    xrandr --output HDMI1 --off --output LVDS1 --auto
    MONITOR=LVDS1
}

# functions to check if HDMI is connected and in use
function HDMIActive {
    [ $MONITOR = "HDMI1" ]
}
function HDMIConnected {
    ! xrandr | grep "^HDMI1" | grep disconnected
}

# actual script
while true
do
    if ! HDMIActive && HDMIConnected
    then
        ActivateHDMI
    fi

    if HDMIActive && ! HDMIConnected
    then
        DeactivateHDMI
    fi

    sleep 1s
done