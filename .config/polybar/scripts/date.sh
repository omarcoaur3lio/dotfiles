#!/bin/bash

TODAY="$(($(date +'%d') + 0))"

(
echo "^fg(#DCDCDC)^fn(Iosevka:pixelsize=12:antialias=True:hinting=True) Calendar"; echo
\
cal -w | sed -re "s/^(.*[A-Za-z][A-Za-z]*.*)$/^fg(#FFFFFF)^bg(#C02A4C)\1/;s/(^|[ ])($TODAY)($|[ ])/\1^bg(#C02A4C)^fg(#FFFFFF)\2^fg(#6C6C6C)^bg(#111111)\3/"
sleep 20
) | dzen2 -fg '#FCFCFC'  -bg '#111111' -fn 'Iosevka:pixelsize=11:antialias=True:hinting=True' -x 1215 -y 40 -w 143 -l 9 -sa c -e 'onstart=uncollapse;button3=exit'
