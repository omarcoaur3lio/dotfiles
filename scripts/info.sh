#!/bin/bash
 
OS=$(awk < /etc/arch-release -F- '{print $1}')
KERNEL=$(uname -r)
ARCH=$(uname -m)
UPTIME=$(awk '{printf("%d:%02d:%02d:%02d",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}' /proc/uptime)
MODEL=$(cat /sys/devices/virtual/dmi/id/board_{name,vendor} | awk '!(NR%2){print$1,p}{p=$0}')
DE='BSPWM'
CPU=$(awk < /proc/cpuinfo '/model name/{gsub(/[(TMR)]/,"");print $4,$5,$6,$8}' | head -1)
GPU="NVIDIA GeForce GT 635M"
SHELL=$(echo "$SHELL" | awk -F/ '{for ( i=1; i <= NF; i++) sub(".", substr(toupper($i),1,1) , $i); print $NF}')
RESOLUTION=$(xdpyinfo | awk '/dimensions:/ {printf $2}')
BIRTH=$(ls -alct /|sed '$!d'|awk '{print $7, $6, $8}')
 
 
GtkTheme=$(awk < .gtkrc-2.0 -F'"' '/gtk-theme-name/{print $2}')
GtkIcon=$(awk < .gtkrc-2.0 -F'"' '/gtk-icon-theme-name/{print $2}' )
GtkFont=$(awk < .gtkrc-2.0 -F'"' '/gtk-font-name/{print $2}')
 
 
Packages=$(pacman -Q|wc -l)
Layout=$(setxkbmap -print | awk -F"+" '/xkb_symbols/{for ( i=1; i <= NF; i++) sub(".", substr(toupper($i),1,1) , $i); print $2}')
Monitor=$(awk < /var/log/Xorg.0.log '/Display/{print $6,$7}'|tr -d '()'|sed -n '1p')
Git='https://github.com/sgtmarcoaurelio' 
 
 echo  ""
 echo -e "\e[91m   "
 echo "   	     SYSTEM INFORMATION"
 echo "   "
 echo  ""
 echo -e "\e[91m    	A54RCH"
 echo -e "\e[97m   	\e[39m$MODEL"
 echo -e "\e[97m    	\e[39m$KERNEL"
 echo -e "\e[97m     	\e[39m$UPTIME"
 echo -e "\e[97m    	\e[39m$SHELL"
 echo -e "\e[97m    	\e[39m$RESOLUTION"
 echo -e "\e[97m    	\e[39m$CPU"
 echo -e "\e[97m    	\e[39m$GPU"
 echo -e "\e[98m   "
 echo -e "\e[97m     	\e[31m$DE"
 echo -e "\e[97m     	\e[39m$GtkTheme"
 echo -e "\e[97m    	\e[39m$GtkIcon"
 echo -e "\e[97m     	\e[39m$GtkFont"
 echo -e "\e[97m    	\e[39m$BIRTH"
 echo -e "\e[98m   "
 echo -e "\e[97m    	\e[31m$Packages"
 echo -e "\e[97m    	\e[39m$Layout"
 echo -e "\e[97m    	\e[39m$Monitor"
 echo -e "\e[97m   	\e[39m$Git"
 echo  ""



