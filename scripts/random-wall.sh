#!/bin/bash

shopt -s nullglob
# cd /home/marco/Imagens/wallpaper\ Arch\ Linux\ 2017/
# cd /home/marco/Imagens/wallpaper-mountains
cd /home/marco/Imagens/Arch-FS-Wall/

while true; do
	files=()
	for i in *.jpg *.png; do
		[[ -f $i ]] && files+=("$i")
	done
	range=${#files[@]}

	((range)) && feh --bg-scale "${files[RANDOM % range]}"
	
	sleep 10m
done