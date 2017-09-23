#!/bin/bash

#::::::::::::::::::::::::::::::::
#       ╻ ╻╻┏┓╻╻╺┳╸┏━┓┏━╸      ::
#       ┏╋┛┃┃┗┫┃ ┃ ┣┳┛┃        ::
#      ╹╹ ╹╹╹ ╹╹ ╹ ╹┗╸┗━╸      ::
# by: asarch                   ::
#::::::::::::::::::::::::::::::::

sxhkd & ;
#xrdb ~/.Xresources & ;
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources & ;
xsetroot -cursor_name left_ptr & ;
exec bspwm
