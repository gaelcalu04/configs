#!/bin/sh   

list=( "git" "vim" "zsh" )   
for element in "${list[@]}"    
    do
	sudo apt-get install -y $element
    done
