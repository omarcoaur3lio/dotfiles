#!/bin/bash

pac=$(checkupdates|perl -lne 'END { print $. }' )
aur=$(cower -u| perl -lne 'END { print $. }' )

check=$((pac + aur))
if [[ "$check" != "0" ]]
then
    echo "%{F#D919C8}%{F-}  Pac $pac Aur $aur"
fi
